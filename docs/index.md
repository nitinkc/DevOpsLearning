# DevOps Learning Labs

Welcome to **DevOps Learning Labs** — a comprehensive, structured learning journey through the entire DevOps and Kubernetes ecosystem.

# DevOps Games
[https://devops.games/](https://devops.games/)

# K8s Games
[https://k8sgames.com/](https://k8sgames.com/)

## 🎯 What This Project Is

A **practical, open-source, teachable** learning environment that takes you from Docker basics all the way through 
**multi-region Kubernetes deployments with GitOps automation**, observability, and advanced patterns.

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

## updated plan

## Project: "Orders API" — a small service you ship through the full real-world path

**The shape of it:** a tiny HTTP API (2-3 endpoints — could literally be `/orders`, `/orders/:id`, `/health`) that you 
deploy, expose, scale, break, fix, and monitor — on your real GKE cluster, through your real GitLab pipeline.

| Stage | What you add                                 | Concepts it forces you to actually use                                                                                    |
|:------|:---------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------|
| 1     | Containerize it, deploy raw manifests to GKE | Docker, Pod, Deployment, ClusterIP Service                                                                                |
| 2     | Expose it properly                           | NodePort → LoadBalancer → Ingress w/ a real hostname, TLS                                                                 |
| 3     | Externalize config                           | ConfigMap + Secret (e.g. a fake DB connection string)                                                                     |
| 4     | Package it                                   | Helm chart — templatize everything above                                                                                  |
| 5     | Automate it                                  | GitLab CI/CD pipeline: build → push to Artifact Registry → Helm deploy to GKE on every push                               |
| 6     | Make it scale                                | Add a CPU-heavy endpoint, load-test it, watch HPA react in real time                                                      |
| 7     | Make it observable                           | Prometheus scraping custom metrics, Grafana dashboard, alert rule                                                         |
| 8     | Make it break (on purpose)                   | Bad image tag through the pipeline → failed rollout → automatic rollback                                                  |
| 9     | Make it accountable                          | GCP billing export → cost panel in the same Grafana instance                                                              |
| 10    | Prove you own it                             | Kill a pod mid-traffic, diagnose a deliberately misconfigured probe, explain the entire request path from your own memory |
