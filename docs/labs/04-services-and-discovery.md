# Lab 04: Services & Discovery

## Objectives

- ✅ Create Services (ClusterIP, NodePort)
- ✅ Understand service discovery & DNS
- ✅ Test pod-to-pod communication
- ✅ Port-forward for local testing
- ✅ Access services from outside cluster

## Prerequisites

- Lab 03 complete (Deployment running)
- ~1 hour

## Step 1: Create ClusterIP Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  type: ClusterIP
  selector:
    app: api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
```

Deploy:

```bash
kubectl apply -f api-service.yaml

# Get service details
kubectl get service api-service
# Note: CLUSTER-IP should be something like 10.x.x.x (internal)

kubectl describe service api-service
```

## Step 2: Test Service Discovery

```bash
# Get service DNS name
service_dns="api-service.default.svc.cluster.local"

# Test from inside cluster
kubectl run test-pod --image=curlimages/curl --rm -it -- sh

# Inside pod, run:
curl http://api-service  # Short name (same namespace)
curl http://api-service.default  # With namespace
curl http://api-service.default.svc.cluster.local  # FQDN
# All should return: {"status":"healthy"}

exit  # Exit test pod
```

## Step 3: Create NodePort Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-nodeport
spec:
  type: NodePort
  selector:
    app: api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
    nodePort: 30000
```

Deploy:

```bash
kubectl apply -f api-nodeport.yaml

# Get NodePort details
kubectl get service api-nodeport

# Get Minikube IP
minikube ip  # e.g., 192.168.x.x

# Test external access
curl http://$(minikube ip):30000/health
# Returns: {"status":"healthy"}
```

## Step 4: Port-Forward

```bash
# Forward local port to pod
kubectl port-forward deployment/api-deployment 8000:5000 &

# Test
curl http://localhost:8000/health

# Kill port-forward
pkill -f "port-forward"
```

## Step 5: Service Endpoints

```bash
# View endpoints (actual pods backing service)
kubectl get endpoints api-service

# When a pod becomes unhealthy (readiness fails)
# it's removed from endpoints automatically

# Force pod unhealthy:
kubectl exec <pod-name> -- kill 1

# Watch endpoints (should decrease)
watch kubectl get endpoints api-service

# Pod restarts and comes back
```

## Validation

```bash
# Service exists
kubectl get svc api-service api-nodeport

# Service has endpoints (pods)
kubectl get endpoints api-service
# ENDPOINTS should show 3 pod IPs

# Service is discoverable
kubectl run test --image=curlimages/curl --rm -it -- curl http://api-service
# Returns: {"status":"healthy"}
```

## Challenge (Optional)

Create LoadBalancer service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-lb
spec:
  type: LoadBalancer
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 5000
```

Note: On Minikube, LoadBalancer doesn't get external IP. Use:
```bash
minikube service api-lb  # Opens in browser
```

## Cleanup

```bash
kubectl delete service api-service api-nodeport api-lb 2>/dev/null || true
```

---

**Next**: [Lab 05: ConfigMaps & Secrets](05-configmaps-and-secrets.md)
