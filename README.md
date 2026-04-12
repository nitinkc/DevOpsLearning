# DevOps Learning Labs

**Comprehensive, structured DevOps learning path from Docker to Kubernetes, Helm, and Flux GitOps.**

🎯 **Goal**: Master containerization, orchestration, package management, and GitOps through theory and hands-on labs.

📚 **Topics Covered**:
- Containerization (Docker)
- Kubernetes fundamentals & advanced patterns
- Helm package management
- GitOps with Flux
- Observability (Prometheus, Grafana, Loki)
- Multi-region deployments
- Sidecars & networking patterns
- Security & troubleshooting

---

## 🚀 Quick Start

### 1. Environment Setup (5 minutes)

```sh
python3 -m venv .venv && echo 'Created venv'
```

```shell
source .venv/bin/activate && pip install -r requirements.txt
```

```bash
# Optional: Run setup script to install Minikube and kind
./minikube-setup/install-dependencies.sh macos`
# Start Minikube cluster
./minikube-setup/setup-east-cluster.sh

# Verify setup
kubectl cluster-info
helm version
flux version
```

### 2. Start Learning (Choose Your Path)

**Option A: Guided Path** (Recommended)
```bash
# View documentation locally
mkdocs serve  # Open http://localhost:8000

# Start with Lab 00
cat docs/labs/00-environment-setup.md
```

**Option B: Jump to Theory**
```bash
# Read theory first
cat docs/theory/01-devops-fundamentals.md
```

**Option C: Hands-On Labs Only**
```bash
# Get straight to labs
ls -la docs/labs/
cat docs/labs/01-docker-basics.md
```

---

## 📋 Project Structure

```
├── docs/
│   ├── theory/              # 9 comprehensive theory modules
│   ├── labs/                # 12 progressive lab exercises
│   ├── index.md             # Home page
│   ├── setup.md             # Installation guide
│   ├── interview-prep.md    # Interview preparation
│   └── interview-questions.md # Self-assessment Q&A
│
├── labs/                    # Lab scripts and exercises
├── minikube-setup/          # Cluster setup scripts
├── sample-app/              # Sample microservices
│   ├── api-server/          # Flask REST API
│   └── database-sidecar/    # Example sidecar
│
├── sample-app/config/
│   ├── k8s-manifests/       # Raw Kubernetes YAML
│   └── helm-charts/         # Helm charts
│
├── flux-config/             # GitOps configuration
├── monitoring/              # Observability configs
└── mkdocs.yml               # Documentation config
```

---

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

---

## 🛠️ Technology Stack (All Open-Source)

| Component             | Tool            | Why                         |
|:----------------------|:----------------|:----------------------------|
| **Container Runtime** | Docker CE       | Industry standard           |
| **Local Kubernetes**  | Minikube + kind | Multi-cluster capable       |
| **Orchestration**     | kubectl         | Standard K8s CLI            |
| **Package Manager**   | Helm            | De facto K8s standard       |
| **GitOps**            | Flux CD         | CNCF, enterprise-ready      |
| **Metrics**           | Prometheus      | Time-series DB              |
| **Dashboards**        | Grafana         | Open-source visualization   |
| **Logging**           | Loki            | Lightweight log aggregation |

---

## 📖 How to Use

### For Self-Study

```bash
# 1. Read theory module
cat docs/theory/02-containerization-docker.md

# 2. Do the corresponding lab
cat docs/labs/01-docker-basics.md

# 3. Practice hands-on
# (lab has step-by-step instructions)

# 4. Try the challenge
# (optional deepdive section in each lab)

# 5. Check yourself with interview questions
cat docs/interview-questions.md
```

### For Teaching Others

- All materials are **open-source and teaching-friendly**
- Use Mermaid diagrams for architecture explanations
- Labs are copy-paste ready for students
- Theory modules provide context for deep dives
- Interview questions make great assessment tool

### For Interview Prep

```bash
# 1. Read interview guide
cat docs/interview-prep.md

# 2. Self-assess with Q&A
cat docs/interview-questions.md

# 3. Practice labs to cement understanding
# (hands-on experience is crucial)

# 4. Design exercises from scenarios
```

---

## 🎯 Learning Outcomes

By completion, you'll understand:

✅ **Containerization**: Building optimized Docker images  
✅ **Kubernetes**: Cluster architecture, workloads, networking, storage  
✅ **Helm**: Templating, dependencies, releases, rollbacks  
✅ **GitOps**: Flux automation, drift detection, audit trails  
✅ **Multi-Region**: Geographic distribution, failover  
✅ **Sidecars**: Logging, metrics, security proxies  
✅ **Observability**: Metrics, logs, tracing, alerting  
✅ **Troubleshooting**: Debugging production issues  
✅ **Interview Skills**: Architecture design, trade-off discussion  

---

## 🔧 Required Tools

- **Docker Desktop** or Docker Engine
- **Minikube** (local K8s cluster)
- **kind** (K8s in Docker, optional)
- **kubectl** (K8s CLI)
- **Helm** (K8s package manager)
- **Flux CLI** (GitOps automation)
- **Git** (for version control)

See [Setup Guide](docs/setup.md) for detailed installation.

---

## 🎓 Use Cases

| Use Case | How to Use |
|----------|-----------|
| **Self-Learning** | Follow guided path, code along |
| **Team Onboarding** | Run labs together, assign theory reading |
| **Teaching** | Use theory + labs in classroom/workshop |
| **Interview Prep** | Practice labs, review Q&A |
| **Quick Reference** | Use theory modules for concepts |

---

## 📝 Documentation

All documentation is built with **MkDocs** and includes:

- 📖 Detailed theory explanations
- 🎨 Mermaid diagrams for architecture
- 💻 Code examples (YAML, shell, Python)
- 📋 Step-by-step lab instructions
- ❓ Interview Q&A with answers
- 🔗 Links to external resources

**View locally:**
```bash
mkdocs serve
# Open http://localhost:8000
```

---

## 🚀 Quick Commands

```bash
# Start east cluster
./minikube-setup/setup-east-cluster.sh

# Start west cluster
./minikube-setup/setup-west-cluster.sh

# Setup networking
./minikube-setup/setup-networking.sh

# Teardown all
./minikube-setup/teardown.sh

# View docs locally
mkdocs serve

# Reset everything
minikube delete -p east
kind delete cluster --name west
```

---

## 🤝 Contributing

Found an issue or have improvement? Feel free to:
- Update theory modules for clarity
- Add new lab exercises
- Improve setup scripts
- Contribute monitoring dashboards
- Fix typos or errors

---

## 📚 Resources

- **Kubernetes**: https://kubernetes.io/docs/
- **Helm**: https://helm.sh/docs/
- **Flux**: https://fluxcd.io/flux/
- **Prometheus**: https://prometheus.io/
- **Grafana**: https://grafana.com/

---

## 🎯 Next Steps

1. **[Setup Guide](docs/setup.md)** — Install required tools
2. **[Lab 00](labs/00-environment-setup.md)** — Verify your environment
3. **[Theory 01](docs/theory/01-devops-fundamentals.md)** — Learn DevOps mindset
4. **[Lab 01](labs/01-docker-basics.md)** — Get hands-on with Docker

---

## 📄 License

Open-source and available for educational and personal use.

---

**Ready to start?** 🚀

👉 **[Start with Setup Guide](docs/setup.md)**  
👉 **[Read Theory Modules](docs/theory/01-devops-fundamentals.md)**  
👉 **[Begin Lab 00](labs/00-environment-setup.md)**  

---

**Last Updated**: April 2026  
**Estimated Duration**: 1-2 weeks for standard track  
**All Materials**: 100% open-source, offline-capable
