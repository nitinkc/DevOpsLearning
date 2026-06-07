# Lab 02: Kubernetes Pods

## Objectives

- ✅ Create pod manifests with labels
- ✅ Deploy pods (loaded from dockerhub registry) to K8s cluster
- ✅ Inspect pod details and logs
- ✅ Apply resource requests/limits
- ✅ Understand pod lifecycle

## Prerequisites

- Lab 01 complete
- **Docker image pushed to registry**
- **Minikube cluster running**
- ~1 hour

**Option A: Single Cluster (Quick Start)**
```bash
minikube start --cpus 4 --memory 6144 --driver docker
kubectl cluster-info
```
    
## Steps

### Step 1: Create Pod Manifest

Create `api-pod.yaml`:

??? note "api-pod.yaml"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: api-pod
      labels:
        app: api
        environment: dev
    spec:
      containers:
      - name: api
        image: YOUR_USERNAME/myapp:1.0.0  # Your image
        ports:
        - containerPort: 5000
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 10
    ```

### Step 2: Deploy Pod

```bash
kubectl apply -f api-pod.yaml

# Verify creation
kubectl get pods

# Expected: api-pod in Running state
```

### Step 3: Inspect Pod

```bash
# Detailed info
kubectl describe pod api-pod

# View logs
kubectl logs api-pod

# Watch logs in real-time
kubectl logs -f api-pod

# Get pod IP
kubectl get pod api-pod -o wide
```

### Step 4: Test Pod Access

```bash
# Port-forward to test locally
kubectl port-forward pod/api-pod 8000:5000 &

# Test API
curl http://localhost:8000/health
# Expected: {"status":"healthy"}
```

### Step 5: Inspect Resource Usage

```bash
# Get resource metrics (requires metrics-server)
kubectl top pod api-pod

# Expected output:
# NAME      CPU(cores)  MEMORY(bytes)
# api-pod   50m         120Mi
```
if any issues
```bash
minikube addons enable metrics-server
kubectl -n kube-system rollout status deployment/metrics-server --timeout=120s
kubectl get apiservice v1beta1.metrics.k8s.io -o wide
kubectl top pod api-pod
```

## Validation

```bash
# Pod is running
kubectl get pod api-pod
# STATUS: Running

# Health checks pass
kubectl describe pod api-pod | grep -A5 "Liveness\|Readiness"

# API responds
curl http://localhost:8000/health
```

## Challenge (Optional)

Create multiple pods with different labels:

```bash
kubectl apply -f api-pod.yaml
# Change metadata.name to api-pod-2, api-pod-3
# Deploy 3 instances
kubectl get pods -l app=api
# Expected: 3 pods
```

## Cleanup

```bash
kubectl delete pod api-pod
kubectl delete pod api-pod-2 api-pod-3
```

---

**Next**: [Lab 03: Deployments & Replicas](03-deployments-and-replicas.md)
