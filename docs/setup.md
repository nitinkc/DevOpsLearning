# Setup Guide — Environment Setup
Before starting the labs, you'll need to set up your local development environment with Docker, Kubernetes, Helm, and Flux.

## System Requirements

- **OS**: macOS, Linux, or Windows (WSL2)
- **RAM**: 8 GB minimum (12 GB recommended for multi-cluster)
- **Disk Space**: 20 GB minimum
- **CPU**: 4 cores minimum (6+ recommended)

## 🚀 Quick Setup (Recommended)

### Step 1: Run Automated Installation Script

We've provided a script to automate tool installation. Run it from the project root:

```bash
# macOS (Homebrew)
./minikube-setup/install-dependencies.sh macos

# Linux
./minikube-setup/install-dependencies.sh linux
```

**Note**: Docker Desktop/Engine requires manual installation from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

### Step 2: Verify Installation

Verify all tools are installed:

```bash
cd minikube-setup/
./verify-setup.sh
```

This script checks: Docker, Minikube, kind, kubectl, Helm, Flux, Git.  
**Output**: ✓ for installed, ✗ for missing.

### Step 3: Set Up Kubernetes Clusters

Choose one option:

**Option A: Single Cluster (Quick Start)**
```bash
minikube start --cpus 4 --memory 6144 --driver docker
kubectl cluster-info
```

**Option B: Multi-Cluster (Recommended for labs)**
```bash
cd minikube-setup/
chmod +x *.sh

./setup-east-cluster.sh      # Creates Minikube cluster "east"
./setup-west-cluster.sh      # Creates kind cluster "west"  
./setup-networking.sh        # Connects both clusters

# Verify
kubectl get nodes --context=east
kubectl get nodes --context=kind-west
```

---

## Manual Tool Installation (Reference)
If the automated script doesn't work, install tools individually:

### **1. Docker Desktop or Docker Engine**
Install from: https://www.docker.com/products/docker-desktop

**Verify:**
```bash
docker --version
docker run hello-world
```

### **2. Minikube** (for single cluster)
Install from: https://minikube.sigs.k8s.io/docs/start/

```bash
# macOS
brew install minikube

# Linux
curl -LO https://github.com/kubernetes/minikube/releases/download/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### **3. kind** (for multi-cluster)
Install from: https://kind.sigs.k8s.io/docs/user/quick-start/

```bash
# macOS
brew install kind

# Linux (requires Go)
go install sigs.k8s.io/kind@latest
```

### **4. kubectl**
Install from: https://kubernetes.io/docs/tasks/tools/

```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/
```

### **5. Helm**
Install from: https://helm.sh/docs/intro/install/

```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### **6. Flux CLI**
Install from: https://fluxcd.io/flux/installation/

```bash
# macOS
brew install fluxcd/tap/flux

# Linux
curl -s https://fluxcd.io/install.sh | sudo bash
```

### **7. Git**
Most systems have Git pre-installed:
```bash
git --version

```

## Cluster Setup Scripts — Detailed

The `minikube-setup/` directory contains automated scripts for cluster setup.

### **setup-east-cluster.sh**

Creates a **Minikube cluster** named "east":

- 4 CPUs, 6GB RAM, 1 control-plane node, Docker driver
- Creates `production` and `monitoring` namespaces

```
# Delete existing cluster if present
minikube delete -p east || true

# Create east cluster
minikube start -p east \
  --cpus 4 \
  --memory 6144 \
  --driver docker \
  --nodes 1

# Wait for cluster to be ready
kubectl wait --for=condition=ready node --all --timeout=300s --context=east

# Create namespaces
kubectl create namespace production --context=east || true
kubectl create namespace monitoring --context=east || true

# Verify
kubectl cluster-info --context=east
kubectl get nodes --context=east

```

**Use case**: Fast, lightweight single-node cluster for initial learning.

---

### **setup-west-cluster.sh**

Creates a **kind cluster** named "west":

- 3 nodes (1 control-plane, 2 workers), runs in Docker containers
- Creates `production` and `monitoring` namespaces

```
# Delete existing cluster if present
kind delete cluster --name west || true

# Create kind cluster with 3 nodes
kind create cluster --name west --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:

- role: control-plane
- role: worker
- role: worker
EOF

# Wait for cluster to be ready
kubectl wait --for=condition=ready node --all --timeout=300s --context=kind-west

# Create namespaces
kubectl create namespace production --context=kind-west || true
kubectl create namespace monitoring --context=kind-west || true

# Verify
kubectl cluster-info --context=kind-west
kubectl get nodes --context=kind-west
```

**Use case**: Multi-node cluster for realistic HA and multi-region scenarios.

---

### **setup-networking.sh**

Configures **networking** between east and west clusters:

```bash
# Get cluster IPs
EAST_IP=$(minikube ip -p east)
WEST_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' west-control-plane)

echo "East IP: $EAST_IP"
echo "West IP: $WEST_IP"

# Add routes (may require sudo password)
sudo route add -net $WEST_IP/24 $EAST_IP || true
sudo route add -net $EAST_IP/24 $WEST_IP || true

# Merge kubeconfig so both contexts are accessible
export KUBECONFIG=~/.kube/config:$(kind get kubeconfig-path --name=west)
kubectl config view --flatten > ~/.kube/config.merged
cp ~/.kube/config.merged ~/.kube/config

# Test connectivity
kubectl run test-pod --image=busybox --context=east -- sleep 3600
kubectl exec test-pod --context=east -- ping west-control-plane
```

**Note**: May require `sudo` for route configuration.

---

### **teardown.sh**

**Cleanup script** — deletes all clusters for a clean slate:

```bash
# Delete Minikube east cluster
minikube delete -p east || true

# Delete kind west cluster
kind delete cluster --name west || true

echo "✓ All clusters deleted"
```

Run when you want to start fresh:

```bash
cd minikube-setup/
./teardown.sh
```

## Working with Your Clusters

### Switch Between Clusters

```bash
# Switch context
kubectl config use-context east
kubectl config use-context kind-west

# View all contexts
kubectl config get-contexts
```

### View Resources in Specific Cluster

```bash
# Get pods from east cluster
kubectl get pods --context=east

# Get pods from west cluster
kubectl get pods --context=kind-west

# Get nodes from both
kubectl get nodes --context=east
kubectl get nodes --context=kind-west
```

### Port Forwarding & Remote Commands

```bash
# Port-forward from specific cluster
kubectl port-forward pod/myapp 8000:5000 --context=east

# Run command in specific cluster
kubectl exec -it pod/myapp --context=kind-west -- /bin/bash

# Check cluster info
kubectl cluster-info --context=east
```

### Delete Individual Clusters

```bash
# Delete Minikube cluster
minikube delete -p east

# Delete kind cluster
kind delete cluster --name west
```

## Visual Verification & UI Tools

### **Minikube Dashboard** (Built-in)

View your Minikube "east" cluster visually:

```bash
# Start the dashboard
minikube dashboard -p east

# This opens: http://127.0.0.1:XXXXX
# Shows: Pods, Deployments, Services, Namespaces, Events

```

**What you'll see**:

- ✅ All running pods and their status
- ✅ Deployments and replica counts
- ✅ Services and their endpoints
- ✅ Resource usage (CPU, memory)
- ✅ Events and logs

### **kubectl UI (via Port-Forward)**

Expose Kubernetes UI on your local machine:

```
# Port-forward the dashboard service (east cluster)
kubectl port-forward -n kube-system svc/kubernetes-dashboard 8443:443 --context=east

# Access: https://localhost:8443
```

### **K9s - Terminal UI for Kubernetes** (Optional but recommended)

Interactive terminal UI to navigate your cluster:

```bash
# Install k9s
# macOS
brew install k9s

# Linux
curl -sS https://webinstall.dev/k9s | bash

# Launch k9s
k9s --context=east

# Key shortcuts:
# :pods         → View pods
# :deploy       → View deployments
# :svc          → View services
# :nodes        → View nodes
# d             → Describe resource
# l             → View logs
# ? or h        → Help
```

**K9s is great for**:

- 🔍 Real-time pod monitoring
- 📋 Quick viewing of logs
- 🔧 Navigating resource hierarchies
- 💡 Learning Kubernetes structure

### **Lens IDE** (Optional - Visual K8s IDE)

Enterprise-grade visual IDE for Kubernetes:

```bash
# macOS — install to user Applications folder (no sudo required)
brew install --cask lens --appdir ~/Applications

# If that still fails, download directly:
# https://k8slens.dev → Download → macOS

# Linux
# https://github.com/MuhammedKalkan/OpenLens/releases

# Launch and add your cluster context (east)
open ~/Applications/Lens.app
```

**Lens provides**:

- 🎨 Beautiful cluster visualization
- 📊 Real-time metrics and dashboards
- 🔍 Advanced debugging tools
- 📦 Helm chart management UI

---

### **OpenLens** (Free, Open-Source Alternative to Lens)

Fully open-source fork of Lens with the same features:

```bash
# macOS
brew install openlens 
# OR
brew install --cask openlens --appdir ~/Applications

# installs at /opt/homebrew/Caskroom/openlens/**

# Linux — Download from GitHub
# https://github.com/MuhammedKalkan/OpenLens/releases

# Launch OpenLens
openlens
```

**OpenLens provides** (same as Lens, 100% free):

- 🎨 Beautiful cluster visualization
- 📊 Real-time metrics and dashboards
- 🔍 Advanced debugging tools
- 📦 Helm chart management UI
- ✅ No enterprise license needed

---

### **Kubeapps** (Lightweight Open-Source Web UI)

Web-based, easy to run in your cluster:

```bash
# Add Bitnami Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install Kubeapps on your cluster
helm install kubeapps bitnami/kubeapps --namespace kubeapps --create-namespace

# Port-forward to access the UI
kubectl port-forward -n kubeapps svc/kubeapps 8080:80

# Access: http://localhost:8080
```

**Kubeapps provides**:

- 🎨 Clean, simple web interface
- 📦 Helm chart browsing and installation
- 🔍 Cluster overview (deployments, services, pods)
- ✅ Runs inside your cluster, not a separate tool
- ✅ 100% open-source

---

### **Comparison of UI Tools**

| Tool                   | Type        | Cost              | Best For                                |
|:-----------------------|:------------|:------------------|:----------------------------------------|
| **Minikube Dashboard** | Web UI      | Built-in          | Quick pod/deployment viewing            |
| **K9s**                | Terminal UI | Free, Open-Source | Power users, fast navigation            |
| **kubectl UI**         | Web UI      | Built-in          | Minimal setup                           |
| **OpenLens**           | Desktop IDE | Free, Open-Source | Visual cluster management (recommended) |
| **Kubeapps**           | Web UI      | Free, Open-Source | Helm charts + cluster overview          |
| **Lens IDE**           | Desktop IDE | Freemium/Paid     | Enterprise features                     |

**Recommendation**: Use **OpenLens** (free) or **K9s** (terminal) for this learning path.

### **Docker Desktop Dashboard** (Built-in)

Monitor Docker containers visually:

```bash
# Open Docker Desktop (already installed)
# Go to: Containers tab

```

**See**:

- ✅ All running containers
- ✅ CPU/Memory usage
- ✅ Container logs in real-time
- ✅ Port mappings

---

## Docker Registry Setup (Optional)

For pushing images to a registry:

### **Using Docker Hub**
```
# Create free account at https://hub.docker.com

# Login locally
docker login

# Tag your images
docker build -t yourusername/myapp:1.0.0 .
docker push yourusername/myapp:1.0.0
```

### **Using GitHub Container Registry (GHCR)**
```bash
# Create GitHub personal access token with packages:write permission

# Login
echo $PAT | docker login ghcr.io -u USERNAME --password-stdin

# Tag and push
docker build -t ghcr.io/yourusername/myapp:1.0.0 .
docker push ghcr.io/yourusername/myapp:1.0.0
```

## Configuration Files

Key configuration files are typically located at:

```bash
# Kubernetes config
~/.kube/config

# Docker config
~/.docker/config.json

# Helm cache
~/.cache/helm/

# Flux cache
~/.cache/flux/
```

## Troubleshooting Setup

### **Minikube won't start**
```bash
# Check if Docker is running
docker ps

# Delete and recreate cluster
minikube delete
minikube start --cpus 4 --memory 6144 --driver docker
```

### **kubectl can't connect to cluster**
```bash
# Check context
kubectl config current-context

# Switch context if needed
kubectl config use-context minikube

# Verify cluster
kubectl cluster-info
```

### **Out of disk space**
```bash
# List Docker images
docker images

# Remove unused images
docker image prune -a

# Delete old clusters
minikube delete
kind delete cluster --name east
kind delete cluster --name west
```
