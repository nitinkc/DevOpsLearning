#!/bin/bash

# Setup script for kind "west" cluster
# Usage: ./setup-west-cluster.sh

set -e

echo "🚀 Setting up kind 'west' cluster..."

# Delete if exists
kind delete cluster --name west || true

# Create kind cluster
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

echo "✓ West cluster ready"

# Create namespaces
kubectl create namespace production --context=kind-west || true
kubectl create namespace monitoring --context=kind-west || true

echo "✓ Namespaces created"
echo ""
echo "West cluster setup complete!"
echo "Context: kind-west"
echo ""
echo "To use west cluster:"
echo "  kubectl cluster-info --context=kind-west"
echo "  kubectl get pods --context=kind-west"
