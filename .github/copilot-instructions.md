## Copilot Context: DevOps Learning Labs (consolidated)

### Project Overview
- **Goal**: Structured, comprehensive DevOps learning path from Docker to Kubernetes, Helm, and Flux
- **Environment**: Minikube + kind for multi-cluster, all open-source tools
- **Documentation**: MkDocs with 9 theory modules, 12 hands-on labs, interview prep
- **Target Audience**: Self-learners, team onboarding, training instructors, career changers

### Project Structure

**Simple organization:**
- **docs/**: All documentation (theory modules, labs, interview prep, setup guides)
- **labs/**: Lab exercise files
- **minikube-setup/**: Cluster setup scripts
- **sample-app/**: Example Flask API with Dockerfile, K8s manifests, Helm charts
- **flux-config/**: GitOps configuration examples
- **monitoring/**: Observability stack configurations

### Theory Modules — What Each Covers

Each theory module includes:
- **Clear Definitions**: Precise concept definition and "what it means"
- **Real-World Examples**: Code snippets (YAML, shell, Python), scenarios
- **Mermaid Diagrams**: Visual architecture, workflows, relationships
- **Comparison Tables**: Quick reference (e.g., Service types, workload types)
- **Best Practices**: Do's and don'ts with justifications
- **Anti-Patterns**: Common mistakes and how to avoid
- **Interview Questions**: Key Q&A for assessment

| # | Module | Focus Areas |
|---|--------|-----------|
| 1 | **DevOps Fundamentals** | Mindset, CI/CD principles, value stream, culture |
| 2 | **Containerization & Docker** | Images, layers, Dockerfile, registries, multi-stage builds |
| 3 | **Kubernetes Fundamentals** | Cluster architecture, pods, deployments, services, namespaces |
| 4 | **Workloads & Deployments** | Deployment, StatefulSet, DaemonSet, Job, rolling updates, HPA |
| 5 | **Networking & Storage** | Services, Ingress, ConfigMaps, Secrets, PV, PVCs, sidecars |
| 6 | **Helm: Package Management** | Chart structure, templating, dependencies, hooks, releases |
| 7 | **GitOps & Flux** | GitOps principles, Flux architecture, HelmRelease, drift detection |
| 8 | **Observability** | Prometheus metrics, Grafana dashboards, Loki logs, alerting |
| 9 | **Advanced Patterns** | Multi-region, sidecars, security, HPA/VPA, chaos engineering |

### Lab Exercises — Progressive Learning Path

**12 hands-on labs** with step-by-step instructions, validation checks, and optional challenges:

| Phase | Labs | Focus | Duration |
|-------|------|-------|----------|
| Phase 1 | 00-01 | Docker + environment | 2 hrs |
| Phase 2 | 02-05 | K8s fundamentals | 4.5 hrs |
| Phase 3 | 06 | Helm charts | 2 hrs |
| Phase 4 | 07-08 | Multi-region + sidecars | 3.5 hrs |
| Phase 5 | 09-10 | Flux + observability | 3.5 hrs |
| Phase 6 | 11 | Troubleshooting | 2 hrs |
| **Total** | **12 labs** | **Full DevOps stack** | **~17.5 hrs** |

### Key Learning Areas & Conventions

#### **1. Containerization** (Theory 02, Lab 01)
- Dockerfile best practices: multi-stage, specific versions, minimal images
- Images as immutable blueprints; containers as instances
- Layer caching speeds up builds
- Non-root users, health checks, .dockerignore
- Registries: Docker Hub, GHCR, ECR

#### **2. Kubernetes Core** (Theory 03-05, Labs 02-05)
- Pods are ephemeral, use Deployments
- Services provide stable networking (ClusterIP, NodePort, LoadBalancer)
- ConfigMaps/Secrets for configuration
- PersistentVolumes for stateful data
- Resource requests/limits prevent overload
- Labels + selectors organize resources

#### **3. Helm & Templating** (Theory 06, Lab 06)
- Charts = templates + values + dependencies
- Templating removes duplication across manifests
- values.yaml for defaults, environment overrides
- Releases = version-tracked deployments
- Easy upgrades and instant rollbacks
- Hooks for DB migrations, post-install tasks

#### **4. GitOps & Flux** (Theory 07, Lab 09)
- Git = single source of truth
- Flux auto-syncs cluster to match Git every 1 min
- HelmRelease CRD declares desired state
- Drift detection auto-corrects manual changes
- Git commit history = audit trail
- Webhooks enable instant sync (vs. polling)

#### **5. Multi-Region & Sidecars** (Theory 09, Labs 07-08)
- 2+ Minikube/kind clusters simulate geographic regions
- Inter-cluster networking enables communication
- Sidecars = additional container sharing network + storage
- Use cases: logging (collect → ship), metrics proxy, network policies
- Service mesh patterns (Envoy proxy)

#### **6. Observability** (Theory 08, Lab 10)
- **Metrics** (Prometheus): CPU, latency, error rate, custom
- **Logs** (Loki): Discrete events, queryable across pods
- **Traces** (Jaeger optional): Request path through services
- Grafana dashboards visualize Prometheus metrics
- AlertManager triggers actions on thresholds

#### **7. Troubleshooting & Operations** (Lab 11)
- `kubectl logs`, `describe`, `get events` for diagnostics
- Metrics + logs + traces for root cause
- Network policies, DNS, connectivity debugging
- Pod lifecycle issues (Pending, CrashLoopBackOff, OOMKilled)
- Incident response, postmortems, prevention

### Recommended Setup & Workflow

#### **Cluster Configuration**
- **Minikube "east"**: 4 CPU, 6GB RAM, 1 node (control-plane)
- **kind "west"**: 3 nodes (1 control-plane, 2 workers)
- **Networking**: Docker network bridge for inter-cluster communication
- **All offline-capable**: No cloud account required

#### **Local Development**
- Docker Desktop: Build and test images locally
- Helm template: Validate manifests before applying
- kubectl dry-run: Test changes safely
- MkDocs: View documentation offline

#### **Deployment Workflow**
```
Code → Docker image → Helm chart → Flux (GitOps sync)
```

#### **Interview Prep** (Tier-Based Learning Path)

**Tier 1 (Junior Level) - Fundamentals**
- Container Basics: Docker images, Dockerfile layers, caching, multi-stage builds
- Kubernetes Core: Pods, Deployments, control plane components, kubectl
- Kubernetes Networking: Service types (ClusterIP, NodePort, LoadBalancer)
- Troubleshooting Basics: Debugging CrashLoopBackOff and common pod issues

**Tier 2 (Mid-Level) - Intermediate**
- Advanced Workloads: Deployment vs. StatefulSet vs. DaemonSet, rolling updates
- Storage & Configuration: PV/PVC, ConfigMaps, Secrets
- Package Management: Helm concepts, install vs. upgrade, environment management
- Observability: Three pillars (metrics, logs, traces), debugging latency

**Tier 3 (Senior Level) - Advanced**
- GitOps & Strategies: Flux vs. Jenkins, multi-cluster GitOps, canary deployments
- Architecture: Multi-region design, sidecars and network proxies
- Security: Secret management (K8s, Sealed Secrets, Vault), Network Policies, zero-trust
- Operations: Incident response, SLA/SLO/SLI, reliability patterns

**Practical Scenarios**
- Design questions: High-traffic API deployment architecture
- Incident response: Production troubleshooting and root cause analysis
- Cost optimization: Kubernetes bill reduction strategies

### Markdown & Documentation Standards

#### **List Formatting (Critical)**

**Always add a blank line before starting a list:**

✅ CORRECT:
```markdown
This is a paragraph.

- Item 1
- Item 2
- Item 3
```

❌ WRONG:
```markdown
This is a paragraph.
- Item 1
- Item 2
- Item 3
```

**Guidelines:**
- Lists must be preceded by a blank line
- Use consistent bullet style (- or *)
- Nested lists need proper indentation (2-4 spaces)
- Numbered lists: Use 1. for first item, then continue with numbers
- Mixed lists: Combine bullets/numbers with proper indentation

#### **Markdown Best Practices**

- **Headings**: Use # for H1, ## for H2, ### for H3 (no H1 for subsections)
- **Bold**: Use `**text**` for emphasis
- **Code**: Use backticks for inline code, triple backticks for blocks
- **Tables**: Proper alignment with pipes and dashes
- **Details/Collapsible**: Use `<details><summary>` for Q&A answers
- **Links**: Use `[text](url)` format
- **Line breaks**: One blank line between sections, two for major sections

### Coding Standards & Practices

- **YAML Style**: Proper indentation, meaningful names, labels on resources
- **Helm Charts**: Templating over duplication, environment-specific values
- **K8s Manifests**: Always specify resource requests/limits, health probes
- **Naming**: Kebab-case for resources, descriptive labels
- **Documentation**: Comment "why" not just "what"
- **Testing**: Validate YAML before applying (`kubectl apply --dry-run`)
- **GitOps**: All config in Git, no manual kubectl apply

### Common Development Tasks

#### **Building & Testing**
```bash
# Build Docker image
docker build -t myapp:1.0.0 .

# Test locally
docker run -p 8000:5000 myapp:1.0.0

# Push to registry
docker push yourname/myapp:1.0.0
```

#### **Kubernetes Deployment**
```bash
# Apply manifests
kubectl apply -f deployment.yaml

# Check status
kubectl rollout status deployment/myapp

# View logs
kubectl logs -f deployment/myapp

# Troubleshoot
kubectl describe pod <pod-name>
kubectl get events
```

#### **Helm Operations**
```bash
# Deploy
helm install myapp ./chart -f values-prod.yaml

# Upgrade
helm upgrade myapp ./chart --set image.tag=2.0.0

# Rollback
helm rollback myapp
```

#### **Flux GitOps**
```bash
# Bootstrap Flux
flux bootstrap github --owner=yourname --repo=config

# Monitor GitOps
flux reconcile helmrelease myapp

# Check status
flux get helmreleases
```

### Setup & Execution

#### **Initial Setup**
```bash
# Install dependencies (see setup.md)
pip install -r requirements.txt

# Start Minikube
./minikube-setup/setup-east-cluster.sh
./minikube-setup/setup-west-cluster.sh
./minikube-setup/setup-networking.sh

# Verify
kubectl cluster-info
```

#### **Laboratory Execution**
```bash
# View lab instructions
cat docs/labs/NN-lab-name.md

# Execute step-by-step commands
# Each lab has validation checks

# Try optional challenges

# Cleanup resources
# Lab includes cleanup commands
```

#### **Documentation**
```bash
# View locally
mkdocs serve
# Open http://localhost:8000

# Build static site
mkdocs build
```

### Standards & Best Practices Summary

- **Always specify versions** (base image, Helm chart, K8s API)
- **Resource requests/limits** prevent pod overload and enable scheduling
- **Health checks** (liveness/readiness) keep system healthy
- **Multiple replicas** provide HA (never use replicas: 1)
- **Labels** organize and select resources
- **Namespaces** provide logical isolation
- **GitOps** ensures declarative, audited infrastructure
- **Observability** (metrics + logs) enables effective troubleshooting
- **Security**: RBAC, network policies, pod security, secret encryption

### Commonly Referenced Sections

- **Setup issues?** → See [Setup Guide](docs/setup.md)
- **K8s architecture?** → See [Theory 03](docs/theory/03-kubernetes-fundamentals.md)
- **Helm templates?** → See [Theory 06](docs/theory/06-package-management-helm.md)
- **Troubleshooting?** → See [Lab 11](docs/labs/11-troubleshooting.md)
- **Interview prep (Tier 1-3)?** → See [Interview Preparation Guide](docs/interview-prep.md)
- **Specific tier topics?** → See headings in interview-prep.md:
  - Tier 1: Container Basics, K8s Core, Networking, Troubleshooting
  - Tier 2: Advanced Workloads, Storage & Configuration, Helm, Observability
  - Tier 3: GitOps, Multi-Region, Security, Operations & Reliability

### Teaching & Extensibility

**For Instructors:**
- All materials are teaching-friendly + open-source
- Each theory has Mermaid diagrams for slides
- Labs are hands-on with copy-paste commands
- Interview Q&A makes great assessment tool
- Can extend with additional labs/theory

**For Self-Learners:**
- Comprehensive coverage (9 theory modules)
- Hands-on labs reinforce learning
- Interview Q&A for self-assessment
- Can repeat labs for practice

**For Career Changers:**
- Progressive difficulty (fundamentals → advanced)
- 1-2 week timeline realistic for standard track
- Interview prep helps secure first role
- All skills highly marketable

---

### Update History
- **v1.1** (April 11, 2026): Reorganized interview prep with systematic 3-tier structure (Tier 1-3), added markdown formatting standards, improved list handling guidelines
- **v1.0** (April 2026): Initial release with 9 theory modules, 12 labs, multi-cluster setup, observability stack, interview materials
