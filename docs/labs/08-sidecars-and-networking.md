# Lab 08: Sidecars & Networking

## Objectives

- ✅ Understand sidecar pattern
- ✅ Deploy logging sidecar (collects & forwards logs)
- ✅ Deploy metrics sidecar (proxies metrics)
- ✅ Configure inter-pod communication
- ✅ Understand network proxies

## Prerequisites

- Lab 07 complete
- ~2 hours

## Step 1: Deploy API with Logging Sidecar

??? note "api-with-logging-sidecar.yaml"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: api-with-logging-sidecar
    spec:
      containers:
      # Main application container
      - name: api
        image: YOUR_USERNAME/myapp:1.0.0
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: app-logs
          mountPath: /var/log/app
        # Have app write logs to /var/log/app/app.log
          
      # Logging sidecar (collects & forwards)
      - name: log-forwarder
        image: curlimages/curl  # Simplified for demo
        volumeMounts:
        - name: app-logs
          mountPath: /var/log/app
          readOnly: true
        command:
        - /bin/sh
        - -c
        - |
          while true; do
            if [ -f /var/log/app/app.log ]; then
              echo "=== Logs from app ==="
              tail -f /var/log/app/app.log
            fi
            sleep 5
          done
    
      volumes:
      - name: app-logs
        emptyDir: {}
    ```

Deploy and test:

```bash
kubectl apply -f api-with-logging-sidecar.yaml

# Watch both containers running
kubectl get pod api-with-logging-sidecar
# Should show READY: 2/2

# View logs from sidecar
kubectl logs api-with-logging-sidecar -c log-forwarder

# View logs from app container
kubectl logs api-with-logging-sidecar -c api
```

## Step 2: Deploy API with Metrics Sidecar

??? note "api-with-metrics-sidecar.yaml"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: api-with-metrics-sidecar
    spec:
      containers:
      # Main app (serves on port 5000)
      - name: api
        image: YOUR_USERNAME/myapp:1.0.0
        ports:
        - containerPort: 5000
        - name: metrics-source
          containerPort: 5001  # App metrics port
          
      # Metrics proxy sidecar
      - name: metrics-proxy
        image: prom/node-exporter:latest  # Simplified
        ports:
        - containerPort: 9095  # Expose metrics
        env:
        - name: APP_HOST
          value: "localhost:5001"
    ```

Deploy:

```bash
kubectl apply -f api-with-metrics-sidecar.yaml

# Access metrics (via port-forward)
kubectl port-forward pod/api-with-metrics-sidecar 9095:9095 &

# Query metrics
curl http://localhost:9095/metrics | head -20

pkill -f "port-forward"
```

## Step 3: Deploy API with Network Proxy Sidecar

Simple Envoy-like proxy (demo):

??? note "api-with-proxy-sidecar.yaml"

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: nginx-config
    data:
      nginx.conf: |
        events { worker_connections 1024; }
        http {
          upstream api_backend {
            server localhost:5000;
          }
          server {
            listen 8001;
            location / {
              proxy_pass http://api_backend;
              proxy_set_header X-Forwarded-For $remote_addr;
            }
          }
        }
    
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: api-with-proxy-sidecar
    spec:
      containers:
      # Main API
      - name: api
        image: YOUR_USERNAME/myapp:1.0.0
        ports:
        - containerPort: 5000
        
      # Proxy sidecar (nginx)
      - name: proxy
        image: nginx:latest
        ports:
        - containerPort: 8001
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx
          
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config
    ```

Deploy:

```bash
kubectl apply -f api-with-proxy-sidecar.yaml

# Port-forward through proxy
kubectl port-forward pod/api-with-proxy-sidecar 8001:8001 &

# Test
curl http://localhost:8001/health

pkill -f "port-forward"
```

## Step 4: Network Policy Sidecar Example

Create restrictive network policy:

??? note "YAML example"

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-all
    spec:
      podSelector: {}
      policyTypes:
      - Ingress
      - Egress
      ingress: []
      egress: []
    
    ---
    # Allow specific traffic only
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-api
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
              role: frontend
        ports:
        - protocol: TCP
          port: 5000
    ```

## Step 5: Cross-Pod Communication

Test pods communicating via sidecars:

??? note "frontend-pod.yaml"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: frontend-pod
      labels:
        app: frontend
        role: frontend
    spec:
      containers:
      - name: frontend
        image: curlimages/curl
        command:
        - /bin/sh
        - -c
        - |
          while true; do
            echo "Calling API..."
            curl http://api-with-proxy-sidecar:8001/api/data
            sleep 10
          done
    
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: api-with-proxy-sidecar
    spec:
      selector:
        # Must match pod that has sidecar
      ports:
      - port: 8001
        targetPort: 8001
    ```

Deploy and test:

```bash
kubectl apply -f frontend-pod.yaml

# Watch frontend calling API
kubectl logs -f frontend-pod -c frontend
```

## Step 6: Multi-Container Debugging

```bash
# Enter API container
kubectl exec -it api-with-logging-sidecar -c api -- /bin/sh

# Inside container, see localhost:5001 (sidecar)
curl http://localhost:5001

# Check network namespace is shared
hostname  # Same hostname across containers

# Enable inter-sidecar communication
exit
```

## Validation

```bash
# All sidecars running
kubectl get pod api-with-logging-sidecar
# READY: 2/2

kubectl get pod api-with-metrics-sidecar
# READY: 2/2

# Sidecars functional
kubectl logs api-with-logging-sidecar -c log-forwarder
# Shows logs

# Services exposing sidecars
kubectl get svc
# Services created
```

## Challenge (Optional)

Implement distributed tracing sidecar:

```yaml
# Add jaeger sidecar for tracing
containers:
- name: jaeger-agent
  image: jaegertracing/jaeger-agent:latest
  ports:
  - containerPort: 6831
    protocol: UDP
```

Instrument app to send traces:

```python
from jaeger_client import Config
config = Config(config={'sampler': {'type': 'const', 'param': 1}})
tracer = config.initialize_tracer()

# Trace requests
with tracer.start_active_span('request'):
    # Handle request
    pass
```

## Cleanup

```bash
kubectl delete pod api-with-logging-sidecar
kubectl delete pod api-with-metrics-sidecar
kubectl delete pod api-with-proxy-sidecar
kubectl delete pod frontend-pod
kubectl delete configmap nginx-config
kubectl delete networkpolicy deny-all allow-api
```

---

**Next**: [Lab 09: Flux GitOps](09-flux-gitops.md)
