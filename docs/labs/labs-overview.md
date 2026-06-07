# Labs Overview

This page provides an overview of all 12 lab exercises in the standard learning track. Each lab builds on previous knowledge and includes hands-on, step-by-step instructions.

## Lab Summary Table

| Lab    | Name                   | Duration  | Key Topics                                      |
|:-------|:-----------------------|:----------|:------------------------------------------------|
| **00** | Environment Setup      | 30 min    | Minikube, kubectl, Helm, Flux, Docker           |
| **01** | Docker Basics          | 1-2 hrs   | Dockerfile, image building, pushing to registry |
| **02** | Kubernetes Pods        | 1 hr      | Pod manifests, labels, resource requests        |
| **03** | Deployments & Replicas | 1.5 hrs   | Deployments, scaling, rolling updates           |
| **04** | Services & Discovery   | 1 hr      | ClusterIP, NodePort, LoadBalancer, DNS          |
| **05** | ConfigMaps & Secrets   | 1 hr      | Environment configuration, sensitive data       |
| **06** | Helm Charts            | 2 hrs     | Chart structure, templating, dependencies       |
| **07** | Multi-Region Setup     | 1.5 hrs   | kind/Minikube clusters, networking, contexts    |
| **08** | Sidecars & Networking  | 2 hrs     | Sidecar pattern, logging proxy, metrics proxy   |
| **09** | Flux GitOps            | 1.5 hrs   | Flux installation, HelmRelease, Git sync        |
| **10** | Observability          | 2 hrs     | Prometheus, Grafana, Loki, alerting             |
| **11** | Troubleshooting        | 2 hrs     | Debugging pods, networking, logs, events        |

## Tips for Success

✅ **Do one lab at a time** — Don't skip prerequisites  
✅ **Type the commands** — Don't just copy-paste (builds muscle memory)  
✅ **Try the challenges** — Deepens understanding  
✅ **Break between phases** — Process what you've learned  
✅ **Reference theory modules** — Use them while doing labs  
✅ **Cleanup properly** — Keeps your clusters lean  

---

## Troubleshooting Labs

If you get stuck:

1. **Re-read the lab instructions** — Often the answer is there
2. **Check the theory module** — Understand the "why"
3. **Inspect resources**: 
   ```bash
   kubectl describe pod <name>
   kubectl logs <pod-name>
   kubectl get events
   ```

4. **Check cluster health**:
   ```bash
   kubectl get nodes
   kubectl cluster-info
   ```

5. **Revert and restart** — Use cleanup commands and start over

---

## Next Steps

Ready to get started?

1. **[Lab 00: Environment Setup](00-environment-setup.md)** ← Start here
2. **[Theory 01: DevOps Fundamentals](../theory/01-devops-fundamentals.md)** ← Read first
3. **[Lab 01: Docker Basics](01-docker-basics.md)** ← Then do this
