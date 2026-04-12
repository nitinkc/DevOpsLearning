#!/bin/bash

# Teardown script - clean up all clusters and resources

set -e

echo "🗑️  Tearing down clusters..."

# Delete Minikube clusters
minikube delete -p east || true
minikube delete -p west || true

# Delete kind clusters
kind delete cluster --name west || true

echo "✓ All clusters deleted"
echo ""
echo "Resources cleaned up!"
