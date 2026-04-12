# DevOps Learning Labs

Welcome to **DevOps Learning Labs** — a comprehensive, structured learning journey through the entire DevOps and Kubernetes ecosystem.

## 🎯 What This Project Is

A **practical, open-source, teachable** learning environment that takes you from Docker basics all the way through **multi-region Kubernetes deployments with GitOps automation**, observability, and advanced patterns.

**Perfect for:**

- 📚 **Self-learners** wanting a structured DevOps path
- 👥 **Team onboarding** programs
- 🏫 **Training instructors** looking for comprehensive, repeatable labs
- 💼 **Career changers** building cloud-native skills

## 🏗️ Project Structure

```
├── docs/theory/           # 9 comprehensive theory modules (read-then-implement)
├── labs/                  # 12 hands-on lab exercises (step-by-step + scripts)
├── minikube-setup/        # Multi-cluster setup scripts (east + west regions)
├── sample-app/            # Sample microservices (REST APIs + sidecars)
├── flux-config/           # GitOps configuration examples
└── monitoring/            # Observability stack configs
```

## 📋 Learning Path (Standard Track: ~1-2 weeks)

### **Phase 1: Containerization (Days 1-2)**
- Theory: DevOps fundamentals, Docker concepts
- Labs: 00-01 (Docker basics, image building, pushing to registry)

### **Phase 2: Kubernetes Fundamentals (Days 3-4)**
- Theory: K8s architecture, workloads, networking
- Labs: 02-05 (Pods, Deployments, Services, ConfigMaps, Secrets)

### **Phase 3: Helm & Packaging (Days 5-6)**
- Theory: Helm charts, templating, dependencies
- Labs: 06 (Create and deploy Helm charts)

### **Phase 4: Multi-Region & Sidecars (Days 7-8)**
- Theory: Advanced patterns, multi-cluster architectures
- Labs: 07-08 (2 Minikube clusters, inter-cluster networking, sidecars)

### **Phase 5: GitOps & Observability (Days 9-10)**
- Theory: GitOps principles, Flux, observability
- Labs: 09-10 (Flux deployment, Prometheus, Grafana, Loki)

### **Phase 6: Troubleshooting & Integration (Days 11+)**
- Theory: Advanced debugging, security, performance
- Lab: 11 (Hands-on troubleshooting scenarios)

## 🚀 Quick Start

```bash
# Clone/navigate to the project
cd DevOpsLearning/

# Install MkDocs (for documentation)
pip install -r requirements.txt

# Start the docs locally
mkdocs serve
# Visit http://localhost:8000

# Begin with environment setup
./minikube-setup/setup-east-cluster.sh
./minikube-setup/setup-west-cluster.sh

# Start with Lab 00
cat labs/00-environment-setup.md
```

## 🛠️ Technology Stack (All Open-Source)

| Component | Tool | Why |
|-----------|------|-----|
| **Local Kubernetes** | Minikube + kind | Lightweight, multi-cluster capable |
| **Container Runtime** | Docker CE | Industry standard |
| **K8s Package Manager** | Helm | De facto standard for K8s deployments |
| **GitOps Automation** | Flux CD | CNCF project, enterprise-ready |
| **Metrics** | Prometheus | Time-series DB, Kubernetes-native |
| **Dashboards** | Grafana | Open-source, powerful visualization |
| **Logging** | Loki | Lightweight log aggregation |
| **Tracing** | Jaeger (optional) | Distributed tracing |
| **Container Registry** | Docker Hub / ghcr.io | Free image hosting |
| **K8s UI (Built-in)** | Minikube Dashboard | Visual pod/service management |
| **K8s Terminal UI** | k9s (optional) | Real-time cluster monitoring |
| **K8s IDE** | Lens (optional) | Enterprise visual IDE for K8s |

## 📚 Learning Outcomes

By completing this project, you'll understand:

✅ **Containerization**: Building and optimizing Docker images for production  
✅ **Kubernetes Architecture**: How clusters, nodes, pods, and services work  
✅ **Helm**: Templating, dependencies, upgrades, and rollbacks  
✅ **GitOps**: Using Flux to manage infrastructure as code  
✅ **Multi-Region Deployments**: Load balancing and geographic distribution  
✅ **Service-to-Service Communication**: Sidecars, proxies, and networking  
✅ **Observability**: Metrics, logs, tracing, and dashboards  
✅ **Troubleshooting**: Debugging pods, networking, and performance issues  
✅ **Interview Readiness**: Explaining architecture decisions and trade-offs  

## 🎓 Interview & Self-Assessment

- 📄 **[Interview Prep](interview-prep.md)**: Key concepts for DevOps interviews
- ❓ **[Interview Questions](interview-prep.md)**: Q&A for self-study and validation

## 🔗 Resources & References

- **Kubernetes Official Docs**: https://kubernetes.io/docs/
- **Helm Documentation**: https://helm.sh/docs/
- **Flux CD Documentation**: https://fluxcd.io/flux/
- **Prometheus**: https://prometheus.io/
- **Grafana**: https://grafana.com/

## 📖 How to Use This Project

### **Guided Learning Path**
1. Read the **theory module** for the topic
2. Follow the **step-by-step lab** for hands-on practice
3. Verify your work with **validation checks**
4. Explore the **challenge section** for deeper understanding
5. Clean up with provided **teardown scripts**

### **Reference Material**
- Use **theory modules** for quick lookups and concept review
- Return to **labs** when you need step-by-step execution
- Check **interview questions** before interviews or assessments

### **Teaching Others**
- All materials are **open-source and teaching-friendly**
- Each lab includes **optional deepdive challenges**
- Use **Mermaid diagrams** for explaining architecture
- All tools are **free and offline-capable**

## 🤝 Contributing

Found an issue? Have an improvement? Feel free to:

- Update theory modules for clarity
- Add new lab exercises
- Improve setup scripts
- Contribute monitoring dashboards

## 📝 License

This project is open-source and available for educational and personal use.

---

## 🎯 Quick Links

**First Time?** → Start with [Setup Guide](setup.md)  
**Want Theory?** → Read [Theory Modules](theory/01-devops-fundamentals.md)  
**Ready to Code?** → Jump to [Lab 00](labs/00-environment-setup.md)  
**Preparing for Interview?** → Check [Interview Prep](interview-prep.md)  

---

**Last Updated**: April 2026  
**Recommended Duration**: 1-2 weeks for standard track  
**All Material**: 100% open-source, offline-capable, and teachable
