# DevOps Learning Labs

**Comprehensive, structured DevOps learning path from Docker to Kubernetes, Helm, and Flux GitOps.**

[https://nitinkc.github.io/DevOpsLearning/](https://nitinkc.github.io/DevOpsLearning/)

🎯 **Goal**: Master containerization, orchestration, package management, and GitOps through theory and hands-on labs.

## **Topics Covered**:

- Containerization (Docker)
- Kubernetes fundamentals & advanced patterns
- Helm package management
- GitOps with Flux
- Observability (Prometheus, Grafana, Loki)
- Multi-region deployments
- Sidecars & networking patterns
- Security & troubleshooting

## 🔧 Required Tools

See [Setup Guide](docs/setup.md) for detailed installation.

- **Docker Desktop** or Docker Engine
- **Minikube** (local K8s cluster)
- **kind** (K8s in Docker, optional)
- **kubectl** (K8s CLI)
- **Helm** (K8s package manager)
- **Flux CLI** (GitOps automation)
- **Git** (for version control)

- **Kubernetes**: https://kubernetes.io/docs/
- **Helm**: https://helm.sh/docs/
- **Flux**: https://fluxcd.io/flux/
- **Prometheus**: https://prometheus.io/
- **Grafana**: https://grafana.com/

## 📚 Learning Path (Standard Track: 1-2 weeks)

### Phase 1: Containerization (2 hrs)
- Theory: DevOps Fundamentals, Docker
- Labs: 00-01 (Environment setup, Docker basics)

### Phase 2: Kubernetes Fundamentals (4.5 hrs)
- Theory: K8s architecture, workloads, networking
- Labs: 02-05 (Pods, Deployments, Services, Config)

### Phase 3: Helm & Packaging (2 hrs)
- Theory: Helm charts, templating
- Labs: 06 (Create & deploy Helm charts)

### Phase 4: Multi-Region & Sidecars (3.5 hrs)
- Theory: Advanced patterns, sidecars
- Labs: 07-08 (Multi-cluster, sidecar patterns)

### Phase 5: GitOps & Observability (3.5 hrs)
- Theory: Flux, GitOps, observability
- Labs: 09-10 (Flux setup, monitoring)

### Phase 6: Troubleshooting (2 hrs)
- Lab: 11 (Real-world debugging scenarios)

## 📝 Documentation

All documentation is built with **MkDocs** and includes:

- 📖 Detailed theory explanations
- 🎨 Mermaid diagrams for architecture
- 💻 Code examples (YAML, shell, Python)
- 📋 Step-by-step lab instructions
- ❓ Interview Q&A with answers
- 🔗 Links to external resources

**View locally:**

Create and activate a virtual environment, then install dependencies:
```shell
python3 -m venv .venv && echo 'Created venv'
source .venv/bin/activate
```

Build and serve the documentation:
```bash
pip install -r requirements.txt
mkdocs build
mkdocs serve
# Open http://localhost:8000
```

## 🎯 Next Steps

1. **[Setup Guide](docs/setup.md)** — Install required tools
2. **[Lab 00](labs/00-environment-setup.md)** — Verify your environment
3. **[Theory 01](docs/theory/01-devops-fundamentals.md)** — Learn DevOps mindset
4. **[Lab 01](labs/01-docker-basics.md)** — Get hands-on with Docker
