#!/bin/bash

# Setup script for Minikube "east" cluster
# Usage: ./setup-east-cluster.sh

set -e

echo "🚀 Setting up Minikube 'east' cluster..."

# Delete if exists
minikube delete -p east || true

# Create east cluster
minikube start -p east \
  --cpus 4 \
  --memory 6144 \
  --driver docker \
  --nodes 1

# Wait for cluster to be ready
kubectl wait --for=condition=ready node --all --timeout=300s --context=east

echo "✓ East cluster ready"

# Create namespaces
kubectl create namespace production --context=east || true
kubectl create namespace monitoring --context=east || true

echo "✓ Namespaces created"
echo ""
echo "East cluster setup complete!"
echo "Context: east"
echo ""
echo "To use east cluster:"
echo "  kubectl cluster-info --context=east"
echo "  kubectl get pods --context=east"
