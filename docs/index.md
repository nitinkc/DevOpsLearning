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


## updated plan

**Blog Angles by Week**

| Week | Item | Angle |
|---|---|---|
| 1 | Real 3-node Standard GKE cluster (not Autopilot) | "What Autopilot hides from you" — node pool sizing, machine types, real `kubectl describe node` output |
| 1 | GKE auth via Workload Identity vs static kubeconfig | Practical writeup of the auth model most tutorials skip |
| 2 | Live HPA event under load (hey/k6) | Capture before/during/after pod counts + latency — hard to make interesting on a toy cluster, easy on real infra |
| 2 | Helm chart templating decisions | "Every values.yaml choice, defended" — good technical-depth post |
| 3 | Bad image tag pushed through GitLab CI pipeline | "Here's what actually breaks" — rollout failure + automatic rollback, the stuff generic tutorials skip |
| 3 | GitLab CI → GKE deploy pipeline | Reconciliation model explained in your own words (Flux vs GitLab, same underlying idea) |
| 4 | Cost observability — GCP billing export → Grafana panel | "I hooked up cost monitoring to my own dashboard" — not on the original plan, differentiated content |
| 4 | Live diagnosis of a deliberately broken deployment | Real troubleshooting narrative, not a staged tutorial |

Here's a project that threads every concept from your plan into one continuous build — not isolated labs, but a single app you keep extending, so each new concept has to interact with everything before it (the way it actually would in a real role).

## Project: "Orders API" — a small service you ship through the full real-world path

**The shape of it:** a tiny HTTP API (2-3 endpoints — could literally be `/orders`, `/orders/:id`, `/health`) that you deploy, expose, scale, break, fix, and monitor — on your real GKE cluster, through your real GitLab pipeline.

| Stage | What you add | Concepts it forces you to actually use |
|---|---|---|
| 1 | Containerize it, deploy raw manifests to GKE | Docker, Pod, Deployment, ClusterIP Service |
| 2 | Expose it properly | NodePort → LoadBalancer → Ingress w/ a real hostname, TLS |
| 3 | Externalize config | ConfigMap + Secret (e.g. a fake DB connection string) |
| 4 | Package it | Helm chart — templatize everything above |
| 5 | Automate it | GitLab CI/CD pipeline: build → push to Artifact Registry → Helm deploy to GKE on every push |
| 6 | Make it scale | Add a CPU-heavy endpoint, load-test it, watch HPA react in real time |
| 7 | Make it observable | Prometheus scraping custom metrics, Grafana dashboard, alert rule |
| 8 | Make it break (on purpose) | Bad image tag through the pipeline → failed rollout → automatic rollback |
| 9 | Make it accountable | GCP billing export → cost panel in the same Grafana instance |
| 10 | Prove you own it | Kill a pod mid-traffic, diagnose a deliberately misconfigured probe, explain the entire request path from your own memory |
