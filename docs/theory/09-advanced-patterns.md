# 09: Advanced Patterns

## Multi-Region Deployments

Deploy Kubernetes across multiple geographic regions for:
- **High availability** — Region failure doesn't affect others
- **Low latency** — Users served from nearby region
- **Compliance** — Data residency requirements

```
        Internet
           ↓
    ┌──────────────┐
    │ Global LB*   │
    └──────────────┘
       ↙        ↘
  EAST Region  WEST Region
  (K8s Cluster) (K8s Cluster)
```

*Global LB routes based on:
- Geographic proximity
- Health checks
- Session affinity

### **Implementation**

**Option 1: DNS-based routing**
```
api-east.example.com   → East cluster IP
api-west.example.com   → West cluster IP
api.example.com        → Global LB (routes to nearest)
```

**Option 2: Service Mesh (Istio/Linkerd)**
```
Automatic routing based on latency/availability
```

---

## Sidecars in Depth

### **Pattern: Logging Sidecar**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-logging-sidecar
spec:
  containers:
  # Main application
  - name: app
    image: myapp:1.0.0
    volumeMounts:
    - name: app-logs
      mountPath: /var/log/app
  
  # Logging sidecar (collects and forwards logs)
  - name: log-forwarder
    image: fluent-bit:2.0.0
    volumeMounts:
    - name: app-logs
      mountPath: /var/log/app
      readOnly: true
    env:
    - name: LOKI_URL
      value: "http://loki:3100"

  volumes:
  - name: app-logs
    emptyDir: {}
```

**Flow:**
```
App writes to /var/log/app/app.log
     ↓
Sidecar reads from /var/log/app/ (shared volume)
     ↓
Sidecar parses and ships to Loki
     ↓
Logs queryable in Grafana/Loki
```

### **Pattern: Metrics Sidecar**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-metrics-sidecar
spec:
  containers:
  # Main app (doesn't expose metrics)
  - name: app
    image: myapp:1.0.0
  
  # Metrics sidecar (proxies and augments metrics)
  - name: metrics-proxy
    image: metrics-sidecar:1.0.0
    ports:
    - containerPort: 9095
    env:
    - name: APP_HOST
      value: "localhost:5000"
    - name: METRICS_PORT
      value: "9095"
```

**requests:**
```
curl http://localhost:9095/metrics
```

### **Pattern: Network Sidecar (Envoy)**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-envoy
spec:
  containers:
  - name: app
    image: myapp:1.0.0
    ports:
    - containerPort: 5000
  
  - name: envoy
    image: envoyproxy/envoy:v1.26-latest
    ports:
    - containerPort: 8001  # Envoy proxy port
    volumeMounts:
    - name: envoy-config
      mountPath: /etc/envoy

  volumes:
  - name: envoy-config
    configMap:
      name: envoy-config
```

Envoy intercepts all traffic:
- Rate limiting
- Circuit breaking
- Retry logic
- Load balancing
- Metrics collection

---

## Pod Security Policies

Restrict what pods can do.

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false                    # No privileged mode
  allowPrivilegeEscalation: false     # No elevation
  requiredDropCapabilities:
  - NET_RAW
  - SYS_ADMIN
  volumes:
  - 'configMap'
  - 'emptyDir'
  - 'projected'
  - 'secret'
  - 'downwardAPI'
  - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
```

Apply to pods:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  annotations:
    seccomp.security.alpha.kubernetes.io/pod: runtime/default
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: myapp:1.0.0
```

---

## Resource Quotas & Limits

Prevent namespace from consuming too many resources.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: production
spec:
  hard:
    requests.cpu: "100"      # Max total CPU requested
    requests.memory: "200Gi" # Max total memory requested
    limits.cpu: "200"        # Max total CPU limits
    limits.memory: "400Gi"   # Max total memory limits
    pods: "100"              # Max 100 pods
    services: "10"           # Max 10 services
```

**LimitRange** (per pod defaults if not specified):

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: production-limits
  namespace: production
spec:
  limits:
  - max:
      cpu: "4"
      memory: "8Gi"
    min:
      cpu: "100m"
      memory: "128Mi"
    default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "250m"
      memory: "256Mi"
    type: Container
```

---

## Horizontal Pod Autoscaling (HPA)

Auto-scale pods based on metrics.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

**Scaling behavior:**
```
CPU crosses 70%
     ↓
HPA scales up (add 1-4 pods per minute)
     ↓
CPU normalizes
     ↓
HPA scales down (remove 1 pod per minute)
```

---

## Vertical Pod Autoscaling (VPA)

Auto-adjust resource requests based on actual usage.

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: api-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: api
  updatePolicy:
    updateMode: "auto"  # Auto-apply recommendations
```

VPA monitors and recommends:
```
Current: requests: {cpu: 100m, memory: 256Mi}
Actual usage: {cpu: 45m, memory: 180Mi}
Recommendation: Reduce requests
```

---

## Network Policies (In-Depth)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: multi-tier-policy
spec:
  podSelector:
    matchLabels:
      tier: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 5000
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 53  # DNS
```

---

## Chaos Engineering

Test resilience by intentionally breaking things.

```bash
# Kill random pod every 30 seconds
kubectl create deployment chaos-pod-killer

# Introduce network latency
tc qdisc add dev eth0 root netem delay 100ms

# Simulate node failure
kubectl drain node-1 --ignore-daemonsets

# Test failover
- App continues
- Requests routed to healthy pods
- Alert fires
- No manual intervention needed
```

---

## Interview Questions

**Q: How do you make an application HA across regions?**

A: Deploy to multiple regions, use global load balancer for routing, implement health checks, ensure components (database, cache) are replicated.

**Q: What's the purpose of a sidecar?**

A: Extend functionality without changing main app (logging, metrics, network policies, encryption).

**Q: How do you handle deployments across multi-region without downtime?**

A: Gradual rollout (canary), health checks, instant rollback capability, circuit breakers.

**Q: What's the difference between HPA and VPA?**

A: **HPA** = scale number of pods (horizontal). **VPA** = adjust resource requests (vertical).

---

## Best Practices Summary

✅ **Multi-region** for HA and compliance  
✅ **Sidecars** for cross-cutting concerns (logging, metrics, security)  
✅ **Network policies** restrict pod-to-pod traffic  
✅ **Resource quotas** prevent resource hoarding  
✅ **HPA** for dynamic workloads  
✅ **Pod security policies** enforce security  
✅ **Chaos engineering** validates resilience  

---

## Key Takeaways

✅ **Multi-region deployments provide HA and low latency**  
✅ **Sidecars add functionality without modifying app**  
✅ **Network policies enforce zero-trust networking**  
✅ **HPA/VPA automate scaling decisions**  
✅ **Chaos engineering tests real resilience**  
✅ **Security layers: pod policies, RBAC, secrets encryption**  

---

## Next Steps

- **Do**: [Lab 07: Multi-Region Setup](../labs/07-multi-region-setup.md)
- **Do**: [Lab 08: Sidecars & Networking](../labs/08-sidecars-and-networking.md)
- **Prepare**: [Interview Questions](../interview-questions.md)
