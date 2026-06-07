# 05: Networking & Storage

--8<-- "_abbreviations.md"

## Service Types & Networking

### **ClusterIP (Default)**

Internal communication only (between pods).

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: api-service
    spec:
      type: ClusterIP  # Default
      selector:
        app: api
      ports:
      - protocol: TCP
        port: 80
        targetPort: 5000
    ```

**Pods can reach via DNS:**
```bash
curl http://api-service.default.svc.cluster.local
# Or from same namespace:
curl http://api-service
```

### **NodePort**

Expose on every node's IP.

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: api-service
    spec:
      type: NodePort
      selector:
        app: api
      ports:
      - port: 80
        targetPort: 5000
        nodePort: 30000  # Access via <node-ip>:30000
    ```

**Access from outside:**
```bash
curl http://node-ip:30000
```

### **LoadBalancer**

Cloud provider load balancer (AWS ELB, GCP, Azure).

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: api-service
    spec:
      type: LoadBalancer
      selector:
        app: api
      ports:
      - port: 80
        targetPort: 5000
    ```

**Get external IP:**
```bash
kubectl get svc api-service
# EXTERNAL-IP will show cloud LB IP (after ~1 min)
```

### Service Types - Deep Comparison

| Type | Reachability | Typical Use | Pros | Trade-offs |
|:-----|:-------------|:------------|:-----|:-----------|
| `ClusterIP` | Inside cluster only | Internal microservice-to-microservice calls | Simple, secure default, no external exposure | Not directly reachable from your laptop/browser |
| `NodePort` | `<node-ip>:nodePort` | Lab/dev access, quick external testing | Easy to expose without extra controller | Fixed port range (`30000-32767`), less flexible for production |
| `LoadBalancer` | External IP/DNS | Production north-south traffic | Cloud-native external entry point | Requires cloud LB integration or local LB addon |

### How Kubernetes Service Routing Actually Works

When you call `http://api-service`, Kubernetes does not send traffic directly to a Pod IP by itself. Several components cooperate:

- `CoreDNS` resolves `api-service.default.svc.cluster.local` to the Service `ClusterIP`.
- `kube-proxy` programs node networking rules (iptables/IPVS) for that Service.
- The packet is DNATed from `ClusterIP:port` to one Pod endpoint (`podIP:targetPort`).
- Endpoint membership comes from `EndpointSlice` objects, which are built from label selectors and pod readiness.

Because of this design:

- Pods can restart and get new IPs without clients changing URLs.
- Unready pods are removed from routing automatically.
- Service names remain stable, while backends can change constantly.

### Pod Network Model (Why Pod-to-Pod Works)

Kubernetes follows a flat pod networking model:

- Every Pod gets its own IP.
- Every Pod can (by default) reach every other Pod IP.
- No Pod-level NAT is required for pod-to-pod traffic.

This is implemented by the CNI plugin (for Minikube commonly bridge + kube-proxy rules; in other clusters Calico/Cilium/Flannel, etc.).

### Request Flow Examples

#### 1) In-cluster call via ClusterIP

`frontend-pod -> CoreDNS -> api-service(ClusterIP) -> kube-proxy rules -> api-pod`

#### 2) External call via NodePort

`curl from laptop -> nodeIP:30000 -> kube-proxy rules -> api-service -> api-pod`

#### 3) External call via LoadBalancer

`client -> external LB -> Service -> api-pod`

In local Minikube-on-macOS Docker-driver setups, direct `nodeIP:nodePort` may not be reachable from host networking. `minikube service <name> --url` usually provides a reachable local URL.

---

## Ingress (HTTP Load Balancing)

Route HTTP/HTTPS to different services based on hostname/path.

### Ingress vs Service (Important Concept)

- A `Service` (L4) forwards traffic to pods by IP/port.
- An `Ingress` (L7) routes HTTP/HTTPS by host/path and then forwards to Services.

In practice, you still need both:

- Service exposes app internally.
- Ingress gives one smart HTTP entrypoint for many Services.

### Ingress Controller Requirement

Ingress YAML alone does nothing unless an Ingress controller is running (Nginx, Traefik, HAProxy, etc.).

Quick check:

```bash
kubectl get pods -A | grep -i ingress
kubectl get ingress
```

??? note "YAML example"

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: api-ingress
    spec:
      ingressClassName: nginx  # Use nginx ingress controller
      rules:
      - host: api.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
      - host: web.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
      tls:
      - hosts:
        - api.example.com
        secretName: api-tls-secret
    ```

```
Request to api.example.com → Ingress → api-service → api-pod
Request to web.example.com → Ingress → web-service → web-pod
```

---

## DNS & Service Discovery

K8s DNS automatically creates records:

```
service-name.namespace.svc.cluster.local
```

**Example:**
```bash
# Service: api-service in default namespace
curl http://api-service  # From same namespace (short)
curl http://api-service.default  # Specify namespace
curl http://api-service.default.svc.cluster.local  # FQDN
```

### DNS Resolution Path (Step-by-Step)

1. App asks resolver for `api-service`.
2. Pod `/etc/resolv.conf` search domains expand it (for example: `api-service.default.svc.cluster.local`).
3. Query goes to `CoreDNS` Service (usually `kube-system`).
4. CoreDNS returns Service `ClusterIP`.
5. Client connects to that IP; kube-proxy handles backend pod selection.

Useful checks:

```bash
# Check DNS service and pods
kubectl -n kube-system get svc,pods | grep -E "kube-dns|coredns"

# Launch a temporary debugging shell
kubectl run dns-debug --image=busybox:1.36 --rm -it -- sh

# Inside the pod
nslookup api-service
nslookup api-service.default.svc.cluster.local
cat /etc/resolv.conf
```

### Common DNS and Discovery Mistakes

- Wrong namespace in service name (`api-service.prod` vs `api-service.default`).
- Service selector labels do not match pod labels.
- Pods not Ready, so no endpoints are published.
- NetworkPolicy blocks DNS egress to CoreDNS (`53/UDP` and sometimes `53/TCP`).

---

## Networking Troubleshooting Playbook

Use this order to isolate issues quickly.

### 1) Is the app healthy?

```bash
kubectl get pods -l app=api
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### 2) Does Service select pods?

```bash
kubectl get svc api-service -o yaml
kubectl get pods -l app=api --show-labels
kubectl get endpoints api-service
kubectl get endpointslices -l kubernetes.io/service-name=api-service
```

### 3) Is DNS resolving?

```bash
kubectl run net-debug --image=curlimages/curl --rm -it -- sh

# Inside pod
nslookup api-service
curl -v http://api-service/health
```

### 4) Is network policy blocking traffic?

```bash
kubectl get networkpolicy -A
kubectl describe networkpolicy <policy-name>
```

### 5) Is external entry path correct?

```bash
# NodePort
kubectl get svc api-nodeport
minikube service api-nodeport --url

# Ingress
kubectl get ingress
kubectl describe ingress <ingress-name>
```

### Error Pattern -> Likely Cause

| Symptom | Most likely cause |
|:--------|:------------------|
| `curl: (6) Could not resolve host` | DNS/CoreDNS issue or wrong service name |
| `Connection refused` | App not listening on target port or container crash |
| `Connection timed out` | Network path blocked (policy/firewall/driver networking) |
| Service has `<none>` endpoints | Selector mismatch or pods not Ready |
| Ingress exists but no routing | Ingress controller missing or wrong class |

---

## Storage (PersistentVolumes & Claims)

### **Problem: Container Storage is Ephemeral**

```bash
# Pod writes to /data
# Pod crashes and restarts
# /data is gone!
```

### **Solution: PersistentVolume (PV)**

Cluster-level storage resource.

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-data
    spec:
      capacity:
        storage: 10Gi
      accessModes:
        - ReadWriteOnce  # Single pod can read/write
      storageClassName: standard
      hostPath:
        path: /mnt/data  # Local disk (for dev/testing only)
    ```

### **PersistentVolumeClaim (PVC)**

Request for storage.

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: pvc-data
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 5Gi
    ```

### **Use in Pod**

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: app-with-storage
    spec:
      containers:
      - name: app
        image: myapp:1.0.0
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: pvc-data
    ```

---

## ConfigMaps & Secrets

### **ConfigMap (Non-Sensitive Configuration)**

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
    data:
      DATABASE_HOST: "postgres.default.svc.cluster.local"
      LOG_LEVEL: "INFO"
      CONFIG_FILE: |
        server:
          port: 5000
          debug: false
    ```

**Use in Pod:**

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: app
    spec:
      containers:
      - name: app
        image: myapp:1.0.0
        env:
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: DATABASE_HOST
        volumeMounts:
        - name: config
          mountPath: /etc/config
      volumes:
      - name: config
        configMap:
          name: app-config
    ```

### **Secret (Sensitive Data)**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_PASSWORD: cGFzc3dvcmQxMjM=  # base64 encoded
  API_KEY: c2VjcmV0LWtleQ==
```

**Create from files:**
```bash
kubectl create secret generic app-secret \
  --from-literal=DB_PASSWORD=password123 \
  --from-file=config.json
```

**Use in Pod:**

```yaml
env:

- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: DB_PASSWORD
```

---

## Network Policies

Restrict traffic between pods.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}  # All pods
  policyTypes:
  - Ingress
  ingress: []  # No ingress allowed by default
```

Allow specific traffic:

??? note "YAML example"

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-api-traffic
    spec:
      podSelector:
        matchLabels:
          app: api
      policyTypes:
      - Ingress
      ingress:
      - from:
        - podSelector:
            matchLabels:
              app: frontend
        ports:
        - protocol: TCP
          port: 5000
    ```

---

## Patterns

### **Sidecar Pattern**

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: app-with-sidecar
    spec:
      containers:
      - name: app
        image: myapp:1.0.0
        ports:
        - containerPort: 5000
      
      - name: sidecar-logging
        image: logging-sidecar:1.0.0
        ports:
        - containerPort: 9095
    ```

Both containers share:

- Network namespace (same IP)
- Storage volumes
- Can communicate via localhost

**Use cases:**

- Logging sidecar (collects and forwards logs)
- Metrics sidecar (exposes metrics)
- Security sidecar (encryption proxy)

---

## Interview Questions

**Q: What's the difference between ClusterIP, NodePort, and LoadBalancer?**

A: **ClusterIP** = internal only. **NodePort** = expose on every node at <node-ip>:port. **LoadBalancer** = cloud provider LB (external IP).

**Q: Why use Ingress instead of LoadBalancer?**

A: Ingress is more efficient (single LB for all services) and supports hostname-based routing. LoadBalancer creates separate LB per service (expensive).

**Q: What's ephemeral storage and why use PersistentVolume?**

A: Ephemeral = lost when pod restarts. PersistentVolume = survives pod restarts (for databases, caches, etc.).

---

## Key Takeaways

✅ **Services provide stable endpoints for pods**  
✅ **Ingress for HTTP load balancing and routing**  
✅ **PersistentVolume/Claim for persistent storage**  
✅ **ConfigMap for non-sensitive config, Secret for sensitive data**  
✅ **Sidecar pattern for cross-cutting concerns**  
✅ **Network policies restrict pod-to-pod traffic**  

---

## Next Steps

- **Read**: [Theory 06: Helm](06-package-management-helm.md)
- **Do**: [Lab 04: Services & Discovery](../labs/04-services-and-discovery.md)
