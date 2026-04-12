# Lab 07: Multi-Region Setup

## Objectives

- ✅ Create 2 Kubernetes clusters (east & west)
- ✅ Configure kubectl contexts  
- ✅ Deploy same app to both clusters
- ✅ Set up inter-cluster networking
- ✅ Test cross-cluster communication

## Prerequisites

- Lab 06 complete (Helm chart ready)
- Docker running
- ~1.5 hours

## Step 1: Setup Both Clusters

```bash
# Make scripts executable
chmod +x ../minikube-setup/*.sh

# Setup east cluster (Minikube)
../minikube-setup/setup-east-cluster.sh

# Setup west cluster (kind)
../minikube-setup/setup-west-cluster.sh

# Verify both running
kubectl config get-contexts
# Should show: east and kind-west

# Verify nodes
kubectl get nodes --context=east
kubectl get nodes --context=kind-west
```

## Step 2: Configure Namespaces

```bash
# Create namespaces in east
kubectl create namespace production --context=east
kubectl create namespace monitoring --context=east

# Create namespaces in west
kubectl create namespace production --context=kind-west
kubectl create namespace monitoring --context=kind-west

# Verify
kubectl get ns --context=east
kubectl get ns --context=kind-west
```

## Step 3: Deploy App to East

```bash
# Switch context
kubectl config use-context east

# Deploy via Helm (from Lab 06)
helm install myapp-east ./myapp-chart \
  -n production \
  --set image.tag=1.0.0 \
  --set replicaCount=3

# Verify
kubectl get pods -n production
kubectl get svc -n production

# Get service IP (internal)
kubectl get svc myapp-east-api -n production
# Note: CLUSTER-IP (example: 10.233.x.x)
```

## Step 4: Deploy App to West

```bash
# Switch context
kubectl config use-context kind-west

# Deploy via Helm
helm install myapp-west ./myapp-chart \
  -n production \
  --set image.tag=1.0.0 \
  --set replicaCount=2

# Verify
kubectl get pods -n production
kubectl get svc -n production
```

## Step 5: Setup Inter-Cluster Networking

```bash
# Setup networking config
../minikube-setup/setup-networking.sh

# This sets up routes so pods can reach across clusters
# (May require sudo)
```

## Step 6: Test Cross-Cluster Communication

```bash
# From east, test connection to west
kubectl run test-pod \
  --image=curlimages/curl \
  --rm -it \
  -n production \
  --context=east \
  -- sh

# Inside pod (east cluster):
# Try to reach west cluster service
# (This depends on successful networking setup)

# Alternatively, port-forward to test
kubectl port-forward svc/myapp-west-api 8001:80 \
  -n production \
  --context=kind-west &

# From your machine
curl http://localhost:8001/health

# Kill port-forward
pkill -f "port-forward"
```

## Step 7: Monitor Both Clusters

```bash
# Watch deployments in both clusters simultaneously
echo "=== EAST CLUSTER ==="
kubectl get pods -n production --context=east

echo "=== WEST CLUSTER ==="
kubectl get pods -n production --context=kind-west
```

## Step 8: Failover Scenario

Test what happens if one cluster fails:

```bash
# Simulate east cluster failure
kubectl delete pod -n production -l app=myapp --context=east

# Watch east re-create pods
watch kubectl get pods -n production --context=east

# West cluster is unaffected
kubectl get pods -n production --context=kind-west
# Still running
```

## Step 9: Version Differences

Deploy different versions to different regions:

```bash
# Canary: Deploy v2.0 to west first
helm upgrade myapp-west ./myapp-chart \
  -n production \
  --context=kind-west \
  --set image.tag=2.0.0

# East still on v1.0
helm upgrade myapp-east ./myapp-chart \
  -n production \
  --context=east \
  --set image.tag=1.0.0

# Verify different versions
kubectl get pods -n production --context=east \
  -o jsonpath='{.items[*].spec.containers[0].image}'
# Shows: 1.0.0

kubectl get pods -n production --context=kind-west \
  -o jsonpath='{.items[*].spec.containers[0].image}'
# Shows: 2.0.0
```

## Validation

```bash
# Both clusters running
kubectl get nodes --context=east
kubectl get nodes --context=kind-west
# Both should have nodes

# Apps deployed to both
kubectl get deployment -n production --context=east
kubectl get deployment -n production --context=kind-west
# Both should have myapp

# Networking works
# (If setup-networking.sh succeeded)
kubectl run test \
  --image=curlimages/curl \
  --context=east \
  -n production \
  -it --rm \
  -- curl myapp-west-api.production.svc.cluster.local
# Should return health response (if networking enabled)
```

## Challenge (Optional)

Set up a global ingress pattern:

```bash
# Install nginx ingress to both clusters
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install nginx-ingress ingress-nginx/ingress-nginx \
  --context=east \
  --set controller.service.type=LoadBalancer

helm install nginx-ingress ingress-nginx/ingress-nginx \
  --context=kind-west \
  --set controller.service.type=LoadBalancer

# Create Ingress resources in both
# (Point to myapp-api service in each cluster)
```

## Cleanup

```bash
# Delete releases
helm uninstall myapp-east -n production --context=east
helm uninstall myapp-west -n production --context=kind-west

# Or teardown everything
../minikube-setup/teardown.sh
```

---

**Next**: [Lab 08: Sidecars & Networking](08-sidecars-and-networking.md)
