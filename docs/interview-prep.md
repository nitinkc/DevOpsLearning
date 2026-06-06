# Interview Preparation Guide

## Overview

Preparing for a DevOps role? This guide is organized by **difficulty tier** (Tier 1→3) and **topic area**, progressing from fundamentals to advanced concepts.

**Quick navigation:**

- **Tier 1 (Junior)**: Docker, Kubernetes fundamentals, Services
- **Tier 2 (Mid-level)**: Helm, advanced K8s workloads, observability
- **Tier 3 (Senior)**: GitOps, multi-region, security, advanced patterns

---
## Tier 1: Fundamentals (Junior Level)

### Container Basics (Docker)

**Q1.1: What is a Docker image vs. a container?**

**Image**: A blueprint/template (immutable), like a class definition  
**Container**: A running instance of an image (mutable), like an object

You can have one image and run 100 containers from it.

**Q1.2: What does `docker build` do and what's the output?**

Builds a Docker image from a Dockerfile. Process:

1. Reads Dockerfile instructions
2. Creates layers (for caching)
3. Stores image locally

Output: Docker image (tagged, e.g., `myapp:1.0.0`)

**Q1.3: Explain Dockerfile layers and why caching matters**

Each command in Dockerfile = one layer. Docker caches layers.

Example:

- Layer 1: FROM python:3.11 (200MB, cached)
- Layer 2: COPY requirements.txt (1MB, cached)
- Layer 3: RUN pip install (cached)
- Layer 4: COPY mycode.py (code changed, re-runs)
- Layer 5-end: Re-run

**Why it matters**: Only changed layers rebuild. Saves time.

**Q1.4: What's a multi-stage build and why use it?**

Separate build stage (includes build tools) from runtime stage (minimal). Reduces final image size (e.g., 1GB → 50MB).

Example:
- Build stage: Includes compiler, dependencies, build tools
- Runtime stage: Only binary/app code, minimal OS

Result: Smaller images, faster deployment, less attack surface.

### Kubernetes Core Concepts

**Q1.5: What is a Pod?**

Smallest unit in Kubernetes. Can contain 1+ containers (usually 1).

Containers in a pod:

- Share network namespace (same IP)
- Share storage volumes
- Can communicate via localhost

Pods are ephemeral (transient). Don't create directly; use Deployments.

**Q1.6: What's the difference between a Pod and a Deployment?**

**Pod**: Single instance (ephemeral)  
**Deployment**: Describes desired state (manage 1+ pods)

Deployment handles:

- Replication (run N copies)
- Restarting crashed pods
- Rolling updates
- Scaling

**Best practice**: Always use Deployment, never create Pods directly.

**Q1.7: Explain Kubernetes control plane components**

- **API Server**: REST interface for managing resources
- **etcd**: Distributed key-value store (cluster state)
- **Scheduler**: Assigns pods to nodes
- **Controller Manager**: Enforces desired state (runs controllers for Deployment, StatefulSet, etc.)
- **kubelet**: Runs on each node, manages pod lifecycle
- **kube-proxy**: Network routing on nodes

Together they maintain cluster state and reconcile reality to desired state.

**Q1.8: What does `kubectl apply` do?**

Applies a manifest (YAML) to cluster.

If resource doesn't exist → creates it  
If resource exists → updates it  
If resource removed from manifest → deleted next time

**Idempotent**: Safe to run multiple times.

### Kubernetes Networking

**Q1.9: What are the three Service types?**

1. **ClusterIP** (default): Internal communication only. DNS name: `service-name.namespace.svc.cluster.local`

2. **NodePort**: Expose on every node's IP:port. Accessible from outside cluster.

3. **LoadBalancer**: Cloud provider load balancer. Assigns external IP.

**When to use**:

- ClusterIP: Pod-to-pod communication
- NodePort: External access without cloud LB
- LoadBalancer: Production external access

### Troubleshooting Basics

**Q1.10: How do you debug a CrashLoopBackOff pod?**

- `kubectl logs pod-name` — Check application logs
- `kubectl describe pod pod-name` — See events and exit code
- `kubectl get events` — Check cluster events
- Verify image exists, resource limits not exceeded, dependencies available

Common causes: Bad config, missing dependencies, OOM, permission issues.

---

## Tier 2: Intermediate (Mid-Level)

### Advanced Kubernetes Workloads

**Q2.1: What's the difference between Deployment, StatefulSet, and DaemonSet?**

| Type | Use | Pods |
|------|-----|------|
| **Deployment** | Stateless (APIs, web) | Interchangeable, random names |
| **StatefulSet** | Stateful (databases) | Unique identity (pod-0, pod-1), persistent storage |
| **DaemonSet** | Node-level (logging) | One per node, always |

**When to use**:

- Deployment: 99% of apps
- StatefulSet: PostgreSQL, MongoDB, Redis
- DaemonSet: Filebeat, node exporter, CNI

**Q2.2: How does a rolling update work?**

Kubernetes gradually replaces old pods with new ones:

1. Old version: 3 pods running v1.0
2. Spin up 1 pod v2.0 (4 total)
3. Remove 1 v1.0 (3 total)
4. Repeat until all v2.0

**Benefits**: Zero downtime, automatic rollback if health checks fail

**Controls**: `maxSurge`, `maxUnavailable`

### Kubernetes Storage & Configuration

**Q2.3: What's a Persistent Volume and why do you need it?**

**Problem**: Container storage is ephemeral. Pod restarts = data lost.

**Solution**: PersistentVolume + PersistentVolumeClaim

**PV** = cluster-level storage resource (10GB)  
**PVC** = Pod's request for storage ("I need 5GB")

Pod uses data that survives restarts.

**Use cases**: Databases, cached data, logs.

**Q2.4: How do you pass configuration to containers in Kubernetes?**

Three main approaches:

1. **Environment variables**: Simple key-value pairs
   - ConfigMaps for non-sensitive data
   - Secrets for passwords/tokens (base64 encoded)

2. **Volume mounts**: Files/directories
   - ConfigMap volumes
   - Secret volumes

3. **Command-line arguments**: Passed to container

**Best practice**: Use ConfigMaps for configs, Secrets for credentials.

### Package Management with Helm

**Q2.5: What is Helm and what problem does it solve?**

Helm = "package manager for Kubernetes"

Solves:

- **Duplication**: Templating (values parameterize manifests)
- **Versioning**: Release management
- **Dependencies**: Chart dependencies
- **Upgrades**: Easy updates + rollbacks

Example: Instead of 10 YAML files, one Helm chart with values.

**Q2.6: Explain `helm install` vs. `helm upgrade --install`**

- **helm install**: Creates new release. Fails if release already exists.
- **helm upgrade --install**: Creates if missing, updates if exists.

**Best practice**: Use `--install` for idempotency.

**Q2.7: How do you manage different environments (dev, staging, prod) with Helm?**

Use multiple values files:

```bash
# Dev: 1 replica, small resources
helm install myapp ./chart -f values-dev.yaml

# Prod: 5 replicas, large resources
helm install myapp ./chart -f values-prod.yaml

```

Each file overrides defaults in `values.yaml`.

### Observability & Monitoring

**Q2.8: What are the three pillars of observability?**

1. **Metrics**: Numeric measurements (CPU, latency, error rate)  
   Tool: Prometheus

2. **Logs**: Discrete events with context  
   Tool: Loki

3. **Traces**: Request path across services  
   Tool: Jaeger

Together → complete visibility. Separately → blind spots.

**Q2.9: How do you debug high latency in a Kubernetes service?**

1. **Check metrics**: Prometheus latency queries
2. **Check logs**: Pod logs for errors
3. **Check traces**: Jaeger for service breakdown
4. **Check network**: Network policies, node CPU/memory
5. **Check application**: Profiling, database queries

---

## Tier 3: Advanced (Senior Level)

### GitOps & Deployment Strategies

**Q3.1: What is GitOps and how does Flux differ from Jenkins?**

**GitOps**: Git = single source of truth. Automated agents reconcile cluster to match Git.

| Aspect | Jenkins (Push) | Flux (Pull) |
|--------|---|---|
| **Trigger** | Pipeline runs `helm upgrade` | Flux watches Git |
| **Drift** | No detection | Auto-corrects |
| **Audit** | Pipeline logs | Git commit history |
| **Rollback** | Rerun pipeline | `git revert` |

**Flux benefits**: Better drift detection, audit trail, easier rollback.

**Q3.2: How do you implement multi-cluster GitOps?**

One Git repo, separate directories per cluster:

```
config-repo/
├── clusters/east/
│   └── releases.yaml  (3 replicas)
├── clusters/west/
│   └── releases.yaml  (5 replicas)
└── apps/
    └── api-chart/
```

Each cluster bootstraps Flux to its directory:
```bash
flux bootstrap github --path=./clusters/east
flux bootstrap github --path=./clusters/west
```

Both sync independently from same repo.

**Q3.3: Describe a canary deployment strategy**

Gradually shift traffic to new version:

```
0%    10%    50%    100%
v1    v1/v2  v1/v2  v2
(5min)(10min)(15min)done

```

At each step:

- Monitor error rate, latency
- If issues → rollback
- If healthy → continue

Tools: Flagger + service mesh, or manual with traffic split.

### Multi-Region & Advanced Architecture

**Q3.4: How would you design a multi-region Kubernetes deployment?**

Architecture:
```
Global Load Balancer (Routes by geography/health)
    ├─ East Region (K8s Cluster)
    │  ├─ Data replicated (PostgreSQL read replicas)
    │  └─ Cache (Redis)
    │
    └─ West Region (K8s Cluster)
       ├─ Data replicated
       └─ Cache (Redis)

```

Considerations:

- **Data**: Replicate database, ensure consistency
- **Networking**: Cross-region latency, cost
- **Failover**: Automatic traffic reroute
- **Cost**: Duplicated infrastructure
- **Testing**: Failure scenarios

**Q3.5: What's a sidecar and when do you use it?**

**Sidecar** = additional container in pod (shares network, storage)

**Use cases**:

1. **Logging**: Pod writes logs, sidecar ships to Loki
2. **Metrics**: Sidecar exposes metrics endpoint
3. **Network proxy**: Envoy intercepts traffic (encryption, rate limit, retries)
4. **Security**: Sidecar enforces auth/encryption

**Benefit**: Extend functionality without changing app code.

### Security & Access Control

**Q3.6: How do you manage secrets in Kubernetes securely?**

**Options** (from basic to advanced):

1. **K8s Secrets**: Base64 encoded (not encrypted by default) — OK for dev

2. **Encryption at rest**: Enable in etcd (API server config)

3. **Sealed Secrets**: Encrypt secrets using cluster public key

4. **External Vault**: HashiCorp Vault (external secret management)

5. **Secret operator**: Automatically rotates/syncs secrets

**Best practice**: Use sealed secrets or external vault for production.

**Q3.7: What's Network Policy and how do you implement zero-trust?**

**Network Policy**: Restrict pod-to-pod communication (like firewall)

```
# Deny all traffic by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  # ingress/egress: [] (empty = no traffic allowed)

---
# Allow only specific traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api
spec:
  podSelector:
    matchLabels:
      app: api
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 5000
```

**Zero-trust**: Deny all → explicitly allow needed traffic.

### Production Operations & Reliability

**Q3.8: Debug a production outage: "All requests returning 500 errors"**

**Immediate** (1-2 min):

1. Rollback recent deployment: `helm rollback` or git revert
2. Alert team, update status page
3. Monitor error rate

**Investigate** (parallel):

1. Metrics: Check CPU, memory, network saturation
2. Logs: Filter errors, check timestamps
3. Traces: See which service failing
4. Events: `kubectl get events`
5. Network: DNS, connectivity, policies

**Root cause** (post-incident):

- Post-mortem meeting
- Identify systemic cause (not just symptom)
- Add monitoring/alerting to prevent
- Improve runbooks

**Q3.9: What's SLA/SLO/SLI and why important?**

- **SLA** (Service Level Agreement): Contract with users (99.99% uptime)
- **SLO** (Service Level Objective): Internal goal (99.9% for us)
- **SLI** (Service Level Indicator): Actual measurement (99.87% actual)

**Error budget**: If SLO=99.9%, you can tolerate 0.1% errors.

**Why**:

- SLOs drive reliability decisions
- Error budget prevents "always live" culture
- Balances speed and reliability

---

## Practical Scenarios & Architecture Questions

These are common "design" and "troubleshoot" questions that test breadth and problem-solving.

### Scenario 1: Design a Production Deployment

**Question**: Design a Kubernetes + Helm setup for an API serving 10M requests/day

**Expected answer should cover**:

- **Compute**: Deployment with 3+ replicas, resource requests/limits
- **Auto-scaling**: HPA based on CPU/memory metrics
- **Networking**: Service (ClusterIP), Ingress (external access, TLS)
- **Configuration**: ConfigMaps for settings, Secrets for credentials
- **Storage**: PVC if stateful (database, cache)
- **Security**: NetworkPolicy (restrict traffic), RBAC
- **Observability**: Prometheus metrics, Loki logs, alerting
- **Deployment**: GitOps with Flux or ArgoCD, canary/blue-green strategy
- **Reliability**: Health checks (liveness, readiness), rollback strategy

### Scenario 2: Incident Response

**Question**: Production database is consuming 90% CPU. Users report slow queries.

**Your answer should address**:

- **Immediate** (1-2 min): Scale up database, enable query logging, rate limit if needed
- **Root cause** (5-10 min): Check slow query log, missing indexes, traffic spike?
- **Fix** (15-30 min): Optimize query, add index, adjust connection pool
- **Prevention**: Add monitoring/alerting before threshold, regular query reviews
- **Post-mortem**: Team learning, documentation, update runbooks

### Scenario 3: Cost Optimization

**Question**: Your Kubernetes bill increased 3x. How do you reduce costs?

**Solutions to discuss**:

- Right-size resource requests/limits (avoid over-provisioning)
- Use HPA instead of static scaling
- Implement spot instances for non-critical workloads
- Consolidate to fewer nodes (bin packing)
- Remove unused resources (old deployments, orphaned PVCs)
- Use reserved instances for predictable baseline load
- Consider managed services vs. self-hosted

---

## Self-Assessment Guide

Use this guide to evaluate your readiness:

| Tier | Questions | Expectation | Role Match |
|------|-----------|-------------|-----------|
| **Tier 1** | Container Basics, K8s Core, Services | Answer 90%+ fluently | Junior/Entry-level |
| **Tier 2** | Advanced Workloads, Helm, Observability | Answer 70%+ with thought | Mid-level/Intermediate |
| **Tier 3** | GitOps, Security, Multi-region, Operations | Answer 50%+ (harder) | Senior/Staff |

**How to practice**:

1. **Understand the "why"** — Memorizing answers doesn't work. Know concepts deeply.
2. **Practice hands-on** — Build things, debug real issues, don't just read.
3. **Explain clearly** — Pretend you're teaching someone. Clarity matters in interviews.
4. **Ask clarifying questions** — "Can you clarify the scale?" shows critical thinking.
5. **Admit gaps confidently** — "I haven't worked with that, but I'd approach it by..." is better than guessing.
6. **Time yourself** — Practice 1-2 minute answers. No rambling.

---

## Interview Question Types

DevOps interviews typically ask one of these:

### 1. **Concept/Definition**
"What is a Pod?" → Straightforward definition. Know these cold.

### 2. **Comparison**
"Difference between Deployment and StatefulSet?" → Comparison table in head.

### 3. **Troubleshooting**
"Pod is CrashLoopBackOff. How do you debug?" → Show methodology.

### 4. **Design/Architecture**
"Design a deployment for X scenario." → Think big picture, security, ops.

### 5. **Decision/Trade-off**
"When would you use DaemonSet vs. Deployment?" → Explain trade-offs.

**Tip**: Listen carefully to the question type. Adjust your answer depth accordingly.

---

## Final Checklist

Before your interview:

- ✅ Can you explain core concepts in 1-2 min? (Don't ramble)
- ✅ Do you have hands-on experience with Docker, Kubernetes, Helm?
- ✅ Can you describe a real incident you handled?
- ✅ Do you understand trade-offs (cost vs. complexity, speed vs. safety)?
- ✅ Are you familiar with one observability stack?
- ✅ Can you describe a production system architecture?

**Remember**: Interviews test both technical depth AND communication. Be clear, be honest, ask questions.

**Good luck! 🚀**