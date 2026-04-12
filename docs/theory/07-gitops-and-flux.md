# 07: GitOps & Flux

## GitOps Definition

**GitOps** = Managing infrastructure through Git as the single source of truth.

```
Traditional (Push):
  Jenkins runs: helm upgrade my-app ./chart
      ↓
  Cluster gets updated
  
GitOps (Pull):
  Developer pushes config to Git
      ↓
  Flux watches Git (polling every 1 minute)
      ↓
  Flux detects change, auto-applies it
      ↓
  Cluster reconciles to match Git
```

**Benefits:**
- ✅ Git = audit trail (who changed what, when)
- ✅ Automatic drift detection (cluster != Git → Flux corrects)
- ✅ Declarative (desired state in Git)
- ✅ Easy rollback (revert Git commit)

---

## Flux Architecture

<div class="mermaid">
graph LR
    A["GitHub<br/>(source of truth)"] -->|polling<br/>every 1 min| B["Flux Controller<br/>(in cluster)"]
    B -->|reconcile| C["Kubernetes Cluster"]
    
    style A fill:#e3f2fd
    style B fill:#f3e5f5
    style C fill:#e8f5e9
</div>

### **Components**

| Component | Role |
|-----------|------|
| **Source Controller** | Fetch configs from Git |
| **Helm Controller** | Reconcile Helm releases |
| **Kustomize Controller** | Manage Kustomize patches |
| **Notification Controller** | Send alerts (Slack, etc.) |

---

## Setting Up Flux

```bash
# Install Flux CLI
brew install fluxcd/tap/flux

# Bootstrap Flux on cluster + GitHub (one command!)
flux bootstrap github \
  --owner=yourname \
  --repo=myapp-config \
  --branch=main \
  --path=./clusters/production \
  --personal
  # Creates repo, installs Flux, sets up sync
```

This creates:
```
myapp-config/ (GitHub repo)
├── clusters/
│   └── production/
│       ├── flux-system/           (Flux components)
│       └── releases.yaml          (HelmReleases)
└── .github/workflows/flux-sync.yml
```

---

## HelmRelease CRD

Tell Flux which Helm chart to deploy.

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: api-server
  namespace: production
spec:
  interval: 5m  # Check Git every 5 minutes
  releaseName: api-server  # Helm release name
  
  chart:
    spec:
      chart: microservices
      version: "1.2.3"  # Specific version
      sourceRef:
        kind: HelmRepository
        name: myrepo
  
  values:
    replicaCount: 3
    image:
      tag: "1.0.0"
    autoscaling:
      enabled: true
      maxReplicas: 10
  
  postRenderers:  # Post-process before applying
  - kustomize:
      patchesStrategicMerge:
      - apiVersion: v1
        kind: Service
        metadata:
          name: api-server
        spec:
          type: LoadBalancer
```

---

## GitRepository Source

Tell Flux where to fetch configs from.

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: my-app-config
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/yourname/myapp-config
  ref:
    branch: main
  secretRef:  # SSH key to access private repo
    name: flux-github-deploy-key
```

---

## Helm Repository Source

Tell Flux where to find Helm charts.

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: myrepo-charts
  namespace: flux-system
spec:
  interval: 5m
  url: https://charts.example.com
  secretRef:
    name: helm-repo-creds  # If auth required
```

---

## Drift Detection

If something manually changes the cluster (kubectl edit, etc.), Flux detects and corrects it.

```
Step 1: Intentional cluster change
  kubectl patch deployment api-server --type='json' \
    -p='[{"op": "replace", "path": "/spec/replicas", "value":1}]'
  
Step 2: Flux notices drift
  Flux controller reconciles HelmRelease
  
Step 3: Flux corrects it
  Deployment replicas = 3 (as defined in Git)
  Slack alert: "Corrected manual change to deployment"
```

---

## Multi-Cluster GitOps

Deploy to east AND west clusters from one Git repo:

```
myapp-config/
├── clusters/
│   ├── east/
│   │   ├── flux-system/
│   │   └── releases.yaml      # HelmRelease for east
│   │       └── values: replicas: 5
│   │
│   └── west/
│       ├── flux-system/
│       └── releases.yaml      # HelmRelease for west
│           └── values: replicas: 3
└── apps/
    ├── api-service/
    │   ├── Chart.yaml
    │   └── templates/
```

Both clusters have:
```bash
flux bootstrap github --path=./clusters/east
flux bootstrap github --path=./clusters/west
```

Each cluster reconciles its own directory independently!

---

## Notifications & Alerts

Alert when deployments fail or drift occurs.

```yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Alert
metadata:
  name: deployment-alerts
  namespace: flux-system
spec:
  providerRef:
    name: slack-webhook
  suspend: false
  eventSeverity: error
  eventSources:
  - kind: HelmRelease
    name: '*'
```

```yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Provider
metadata:
  name: slack-webhook
  namespace: flux-system
spec:
  type: slack
  address: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

---

## Flux vs Jenkins (Push) vs GitOps

| Aspect | Jenkins (Push) | Flux (Pull) |
|--------|---|---|
| **Deployment trigger** | Pipeline runs `helm upgrade` | Flux detects Git change |
| **Cluster drift** | No detection | Automatic detection & correction |
| **Audit trail** | Pipeline logs | Git commit history |
| **Rollback** | Manual; rerun pipeline | `git revert` commit |
| **Secrets** | Jenkins secrets store | K8s Secrets (encrypted at rest) |
| **Learn curve** | Medium | Steep initially |

---

## Best Practices

✅ **Keep all config in Git**
```bash
# BAD: Manual kubectl apply
kubectl apply -f manifest.yaml

# GOOD: Push to Git, let Flux apply
git push origin config-change
```

✅ **Use different branches for environments**
```
main             → production cluster
staging          → staging cluster
feature/my-work  → review in branch cluster
```

✅ **Encrypt secrets in Git**
```
Use SOPS or Sealed Secrets, not plaintext
```

✅ **Test before merging**
```
Use preview/ephemeral clusters to test Git changes
```

---

## Interview Questions

**Q: What's the difference between Flux and Jenkins?**

A: **Jenkins** = push-based CD (pipeline deploys). **Flux** = pull-based GitOps (cluster auto-syncs from Git). Flux adds drift detection and audit trail.

**Q: How does Flux detect when to update?**

A: Flux periodically polls Git (default 1 minute). If config changed, Flux applies it.

**Q: Can you rollback with Flux?**

A: Yes, revert the Git commit. Flux will detect the change and roll back the cluster.

---

## Key Takeaways

✅ **GitOps = Git as source of truth**  
✅ **Flux auto-syncs cluster to match Git**  
✅ **HelmRelease declares desired Helm deployments**  
✅ **Drift detection = auto-correction of manual changes**  
✅ **Git commit history = audit trail**  
✅ **Pull model = cluster controls its own destiny**  

---

## Next Steps

- **Read**: [Theory 08: Observability](08-observability.md)
- **Do**: [Lab 09: Flux GitOps](../labs/09-flux-gitops.md)
