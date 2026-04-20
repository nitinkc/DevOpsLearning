# DevOps Learning Labs

Welcome to **DevOps Learning Labs** — a comprehensive, structured learning journey through the entire DevOps and Kubernetes ecosystem.

# DevOps Games
[https://devops.games/](https://devops.games/)

# K8s Games
[https://k8sgames.com/](https://k8sgames.com/)

## 🎯 What This Project Is

A **practical, open-source, teachable** learning environment that takes you from Docker basics all the way through **multi-region Kubernetes deployments with GitOps automation**, observability, and advanced patterns.


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

## 🛠️ Technology Stack (All Open-Source)

| Component               | Tool                 | Why                                   |
|:------------------------|:---------------------|:--------------------------------------|
| **Local Kubernetes**    | Minikube + kind      | Lightweight, multi-cluster capable    |
| **Container Runtime**   | Docker CE            | Industry standard                     |
| **K8s Package Manager** | Helm                 | De facto standard for K8s deployments |
| **GitOps Automation**   | Flux CD              | CNCF project, enterprise-ready        |
| **Metrics**             | Prometheus           | Time-series DB, Kubernetes-native     |
| **Dashboards**          | Grafana              | Open-source, powerful visualization   |
| **Logging**             | Loki                 | Lightweight log aggregation           |
| **Tracing**             | Jaeger (optional)    | Distributed tracing                   |
| **Container Registry**  | Docker Hub / ghcr.io | Free image hosting                    |
| **K8s UI (Built-in)**   | Minikube Dashboard   | Visual pod/service management         |
| **K8s Terminal UI**     | k9s (optional)       | Real-time cluster monitoring          |
| **K8s IDE**             | Lens (optional)      | Enterprise visual IDE for K8s         |

## 🎓Interview & Self-Assessment

- 📄 **[Interview Prep](interview-prep.md)**: Q&A for self-study and validation

## 🔗 Resources & References

- **Kubernetes Official Docs**: https://kubernetes.io/docs/
- **Helm Documentation**: https://helm.sh/docs/
- **Flux CD Documentation**: https://fluxcd.io/flux/
- **Prometheus**: https://prometheus.io/
- **Grafana**: https://grafana.com/


## 🎯 Quick Links

**First Time?** → Start with [Setup Guide](setup.md)  
**Want Theory?** → Read [Theory Modules](theory/01-devops-fundamentals.md)  
**Ready to Code?** → Jump to [Lab 00](labs/00-environment-setup.md)  
**Preparing for Interview?** → Check [Interview Prep](interview-prep.md)  
