#!/bin/bash

# DevOps Learning Labs — Environment Verification Script
# Checks if all required tools are installed and properly configured

echo "=== DevOps Learning Labs — Environment Verification ==="
echo ""

PASS=0
FAIL=0

# Helper function to check tool
check_tool() {
    local tool=$1
    local cmd=$2
    local name=$3

    printf "  %-15s " "$name"
    if eval "$cmd" &>/dev/null; then
        echo "✓"
        ((PASS++))
    else
        echo "✗"
        ((FAIL++))
    fi
}

# Check Docker
check_tool "docker" "docker --version" "Docker"

# Check Minikube
check_tool "minikube" "minikube version" "Minikube"

# Check kind
check_tool "kind" "kind version" "kind"

# Check kubectl
check_tool "kubectl" "kubectl version --client" "kubectl"

# Check Helm
check_tool "helm" "helm version" "Helm"

# Check Flux CLI only
# `flux version` contacts the Kubernetes API server for the current context,
# which can fail during initial setup before any cluster is started.
check_tool "flux" "flux version --client" "Flux"

# Check Git
check_tool "git" "git --version" "Git"

echo ""
echo "=== Summary ==="
echo "✅ Installed: $PASS"
echo "❌ Missing: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 All tools are ready! You can start the labs."
    echo ""
    echo "Next steps:"
    echo "  1. Run: cd minikube-setup && ./install-dependencies.sh macos"
    echo "  2. Run: ./setup-east-cluster.sh && ./setup-west-cluster.sh"
    echo "  3. Read: ../docs/labs-overview.md"
    exit 0
else
    echo "⚠️  Some tools are missing. Run:"
    echo "  ./install-dependencies.sh macos    # or linux"
    exit 1
fi

