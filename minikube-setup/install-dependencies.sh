#!/bin/bash

# DevOps Learning Labs — Automated Dependency Installation
# Usage: ./install-dependencies.sh [macos|linux]

set -e

OS=${1:-macos}

echo "=== DevOps Learning Labs — Installing Dependencies ==="
echo "OS: $OS"
echo ""

if [ "$OS" == "macos" ]; then
    # macOS (Homebrew)
    echo "Installing on macOS..."

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Install from: https://brew.sh"
        exit 1
    fi

    echo "📦 Installing Docker Desktop..."
    # Note: Docker Desktop requires manual installation
    echo "⚠️  Please install Docker Desktop manually from: https://www.docker.com/products/docker-desktop"
    echo "   Then run this script again."

    echo ""
    echo "📦 Installing Minikube..."
    brew install minikube || true

    echo "📦 Installing kind..."
    brew install kind || true

    echo "📦 Installing kubectl..."
    brew install kubectl || true

    echo "📦 Installing Helm..."
    brew install helm || true

    echo "📦 Installing Flux CLI..."
    brew install fluxcd/tap/flux || true

    echo "📦 Installing Git..."
    brew install git || true

elif [ "$OS" == "linux" ]; then
    # Linux
    echo "Installing on Linux..."

    # Check if apt or dnf is available
    if command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        SUDO="sudo"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        SUDO="sudo"
    else
        echo "❌ apt or dnf not found. Unsupported Linux distribution."
        exit 1
    fi

    echo "⚠️  Please install Docker Engine manually from: https://docs.docker.com/engine/install/"
    echo "   Then run this script again."

    echo ""
    echo "📦 Installing Minikube..."
    curl -LO https://github.com/kubernetes/minikube/releases/download/latest/minikube-linux-amd64
    $SUDO install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64

    echo "📦 Installing kind..."
    # Check if Go is installed for kind
    if command -v go &> /dev/null; then
        go install sigs.k8s.io/kind@latest
    else
        echo "⚠️  Go not found. Install from: https://golang.org/doc/install"
        echo "   Then run: go install sigs.k8s.io/kind@latest"
    fi

    echo "📦 Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    $SUDO install kubectl /usr/local/bin/
    rm kubectl

    echo "📦 Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    echo "📦 Installing Flux CLI..."
    curl -s https://fluxcd.io/install.sh | $SUDO bash

    echo "📦 Installing Git..."
    $SUDO $PKG_MANAGER install -y git || true

else
    echo "❌ Unknown OS: $OS"
    echo "Usage: ./install-dependencies.sh [macos|linux]"
    exit 1
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Run this to verify:"
echo "  docker --version"
echo "  minikube version"
echo "  kind version"
echo "  kubectl version --client"
echo "  helm version"
echo "  flux version"
echo ""

