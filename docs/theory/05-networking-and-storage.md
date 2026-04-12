# 05: Networking & Storage

## Service Types & Networking

### **ClusterIP (Default)**

Internal communication only (between pods).

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

---

## Ingress (HTTP Load Balancing)

Route HTTP/HTTPS to different services based on hostname/path.

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
