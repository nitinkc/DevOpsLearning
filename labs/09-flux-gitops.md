# Lab 09: Flux GitOps

## Objectives

- ✅ Install Flux on cluster
- ✅ Create HelmRelease manifests
- ✅ Set up Git synchronization
- ✅ Test auto-sync on Git push
- ✅ Monitor Flux reconciliation

## Prerequisites

- Lab 08 complete
- GitHub account (for storing config)
- Flux CLI installed
- ~1.5 hours

## Step 1: Install Flux

```bash
# Check Flux prerequisites
flux check --pre

# Bootstrap Flux with GitHub
# (Creates flux-system namespace, installs controllers)
flux bootstrap github \
  --owner=YOUR_GITHUB_USERNAME \
  --repo=devops-learning-config \
  --branch=main \
  --path=./clusters/training

# You'll be prompted to create a personal access token
# Creating repo in your GitHub account automatically
```

Verify installation:

```bash
# Check Flux components
kubectl get pods -n flux-system

# Should see:
# - helm-controller
# - source-controller
# - kustomize-controller
# - notification-controller
```

## Step 2: Create HelmRelease

Create `helmrelease.yaml`:

??? note "helmrelease.yaml"

    ```yaml
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: myapp
      namespace: default
    spec:
      interval: 5m  # Check Git every 5 minutes
      releaseName: myapp
      chart:
        spec:
          chart: ./myapp-chart  # Local chart
          sourceRef:
            kind: GitRepository
            name: flux-system
            namespace: flux-system
      values:
        replicaCount: 3
        image:
          tag: "1.0.0"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
    ```

## Step 3: Create HelmRepository Source

For external charts:

??? note "YAML example"

    ```yaml
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: myrepo
      namespace: flux-system
    spec:
      interval: 5m
      url: https://charts.example.com
      secretRef:
        name: helm-credentials  # Optional: for private repos
    ```

## Step 4: Push Config to Git

```bash
# Clone the Flux repo that was created
git clone https://github.com/YOUR_USERNAME/devops-learning-config
cd devops-learning-config

# Create directory
mkdir -p clusters/training

# Add HelmRelease
cp helmrelease.yaml clusters/training/

# Commit and push
git add clusters/training/helmrelease.yaml
git commit -m "Add myapp HelmRelease"
git push origin main
```

## Step 5: Monitor Flux Reconciliation

```bash
# Watch Flux sync the config
kubectl get helmrelease -w

# Check status
kubectl describe helmrelease myapp

# View controller logs
kubectl logs -f -n flux-system deployment/helm-controller

# Check if release created
helm list
```

## Step 6: Test Auto-Update on Git Push

Edit `helmrelease.yaml` in Git:

```yaml
# Change replicas from 3 to 5
spec:
  values:
    replicaCount: 5
```

Push to Git:

```bash
git add clusters/training/helmrelease.yaml
git commit -m "Scale up to 5 replicas"
git push origin main

# Watch Flux detect and apply change
watch kubectl get deployment myapp -o wide
# Should scale to 5 replicas automatically
```

## Step 7: Drift Detection

Intentionally change cluster:

```bash
# Manually scale down
kubectl scale deployment myapp --replicas=2

# Flux detects drift
watch kubectl get deployment myapp
# After ~5 minutes, scales back to 5 (from Git)
```

## Step 8: Alerting (Optional)

Set up Slack notifications:

??? note "YAML example"

    ```yaml
    apiVersion: notification.toolkit.fluxcd.io/v1beta2
    kind: Alert
    metadata:
      name: deployment-alerts
      namespace: flux-system
    spec:
      providerRef:
        name: slack
      eventSeverity: error
      eventSources:
      - kind: HelmRelease
        name: '*'
    
    ---
    apiVersion: notification.toolkit.fluxcd.io/v1beta2
    kind: Provider
    metadata:
      name: slack
      namespace: flux-system
    spec:
      type: slack
      address: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
    ```

Create secret:

```bash
kubectl create secret generic slack-webhook \
  -n flux-system \
  --from-literal=slack-webhook=https://hooks.slack.com/services/YOUR/WEBHOOK
```

## Step 9: Multi-Cluster GitOps

Structure for multiple clusters:


```
configs/
├── clusters/
│   ├── east/
│   │   ├── helmReleases.yaml
│   │   └── kustomization.yaml
│   │
│   └── west/
│       ├── helmReleases.yaml
│       └── kustomization.yaml
│
└── apps/
    └── myapp-chart/
```

Each cluster bootstraps to its directory:

```bash
# East cluster
flux bootstrap github \
  --owner=YOUR_USERNAME \
  --repo=configs \
  --path=clusters/east

# West cluster
flux bootstrap github \
  --owner=YOUR_USERNAME \
  --repo=configs \
  --path=clusters/west
```

## Validation

```bash
# Flux installed
kubectl get pods -n flux-system

# HelmRelease created
kubectl get helmrelease

# Helm release deployed
helm list

# Git source synced
kubectl get gitrepository -n flux-system

# Reconciliation status
kubectl get helmrelease -o wide
# READY should be True
```

## Challenge (Optional)

Implement Kustomization with Flux:

??? note "YAML example"

    ```yaml
    apiVersion: kustomize.toolkit.fluxcd.io/v1
    kind: Kustomization
    metadata:
      name: myapp
      namespace: flux-system
    spec:
      interval: 5m
      path: ./kustomize/overlays/production
      prune: true
      sourceRef:
        kind: GitRepository
        name: flux-system
    ```

## Cleanup

```bash
# Delete Flux
flux uninstall --namespace=flux-system

# Delete HelmRelease
kubectl delete helmrelease myapp

# Delete Git repo (optional)
# rm -rf devops-learning-config/
```

---

**Next**: [Lab 10: Observability](10-observability-monitoring.md)
