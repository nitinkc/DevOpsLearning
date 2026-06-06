# Lab 00: Environment Setup

## Objectives

- ✅ Verify Docker installation
- ✅ Set up Minikube cluster (or kind for multi-region)
- ✅ Install and verify kubectl
- ✅ Configure Helm and Flux CLI
- ✅ Test basic cluster access

## Prerequisites

- Docker Desktop or Docker Engine installed
- ~15 minutes
- Reference: [Setup Guide](../docs/setup.md)

## Steps

### Step 1: Verify Docker

```bash
docker --version
docker run hello-world
```

**Expected output:**
```
Docker version 24.x.x
...
Hello from Docker!
```

### Step 2: Start Minikube Cluster

```bash
# Start single cluster
minikube start --cpus 4 --memory 6144 --driver docker

# Verify it's running
minikube status
```

### Step 3: Configure kubectl

```bash
# Check cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Expected: 1 control plane node (minikube)
```

### Step 4: Verify Helm

```bash
helm version

# Add Bitnami repo (used in labs)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Step 5: Verify Flux CLI

```bash
flux version

# Check if Flux can bootstrap (don't actually run yet)
flux check --pre
```

## Validation

All commands should return version information and success status:

```bash
cat << 'EOF' > /tmp/test-setup.sh
#!/bin/bash
set -e

echo "Testing environment setup..."

# Docker
docker --version && echo "✓ Docker" || (echo "✗ Docker"; exit 1)

# kubectl
kubectl cluster-info && echo "✓ kubectl" || (echo "✗ kubectl"; exit 1)

# Helm
helm version && echo "✓ Helm" || (echo "✗ Helm"; exit 1)

# Flux
flux version && echo "✓ Flux" || (echo "✗ Flux"; exit 1)

echo "✓ All checks passed!"
EOF

chmod +x /tmp/test-setup.sh
/tmp/test-setup.sh
```

## Challenge (Optional)

Create additional namespaces for future labs:

```bash
kubectl create namespace production
kubectl create namespace staging
kubectl create namespace monitoring

kubectl get namespaces
```

## Cleanup

For now, keep cluster running. To reset later:

```bash
minikube delete
```

---

**Next**: [Lab 01: Docker Basics](01-docker-basics.md)
