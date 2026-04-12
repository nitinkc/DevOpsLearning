#!/bin/bash

# Setup networking between east (Minikube) and west (kind) clusters
# Enables cross-cluster communication

set -e

echo "🌐 Setting up inter-cluster networking..."

# Get cluster IPs
EAST_IP=$(minikube ip -p east)
WEST_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' west-control-plane)

echo "East IP: $EAST_IP"
echo "West IP: $WEST_IP"

# Add routes (may require sudo)
echo "Adding routes (you may need to enter sudo password)..."
sudo route add -net $WEST_IP/24 $EAST_IP || true
sudo route add -net $EAST_IP/24 $WEST_IP || true

# Update kubeconfig contexts
echo "Updating kubeconfig..."
KUBECONFIG_ORIGINAL=$KUBECONFIG
export KUBECONFIG=~/.kube/config:$(kind get kubeconfig-path --name=west)
kubectl config view --flatten > ~/.kube/config.merged
cp ~/.kube/config.merged ~/.kube/config

echo "✓ Networking setup complete"
echo ""
echo "Test connectivity:"
echo "  kubectl run test-pod --image=busybox --context=east -- sleep 3600"
echo "  kubectl exec test-pod --context=east -- ping west-control-plane"
