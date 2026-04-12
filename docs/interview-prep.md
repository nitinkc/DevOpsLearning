# Interview Preparation Guide

## Overview

Preparing for a DevOps role? This guide covers key concepts and interview formats.

## Core Interview Topics

### **1. Kubernetes Architecture**

**Q: Explain Kubernetes control plane components**

A: API Server (REST interface), etcd (state store), Scheduler (pod placement), Controller Manager (enforce desired state)

**Q: What's the difference between a Pod and a Deployment?**

A: Pod is single/multiple containers (ephemeral). Deployment manages multiple pods, handles restarts, updates, scaling.

**Q: How do you debug a CrashLoopBackOff pod?**

A:
- `kubectl logs pod-name` — Check application logs
- `kubectl describe pod pod-name` — See events and exit code
- `kubectl get events` — Check cluster events
- Verify image exists, resource limits not exceeded, dependencies available

### **2. Docker & Containerization**

**Q: What's a multi-stage build and why use it?**

A: Separate build stage (includes build tools) from runtime stage (minimal). Reduces final image size (e.g., 1GB → 50MB).

**Q: How do you pass configuration to containers?**

A: Environment variables, volumes (config files), ConfigMaps, Secrets.

**Q: What's the difference between CMD and ENTRYPOINT?**

A: ENTRYPOINT = main process (shouldn't be overridden). CMD = arguments or default command (can be overridden).

### **3. Helm & Templating**

**Q: What problem does Helm solve?**

A: Reduces manifest duplication via templating, manages dependencies, versions releases, easy upgrades/rollbacks.

**Q: How do you manage environment-specific configs with Helm?**

A: Use values files (values.yaml, values-prod.yaml). Override with `-f values-prod.yaml` or `--set key=value`.

**Q: Can you rollback a Helm release?**

A: Yes, `helm rollback <release-name>` reverts to previous version instantly.

### **4. GitOps & Flux**

**Q: What's GitOps and why is it useful?**

A: Git as source of truth. Flux auto-syncs cluster to match Git. Benefits: audit trail, drift detection, easy rollback.

**Q: How does Flux detect when to update?**

A: Polls Git periodically (default 1 min). If config changed, applies it. Can also use webhooks for instant sync.

**Q: Can you roll back with GitOps?**

A: Yes, revert Git commit. Flux detects change and automatically rolls back cluster.

### **5. Networking & Services**

**Q: Explain Service types: ClusterIP, NodePort, LoadBalancer**

A:
- ClusterIP: Internal only, DNS-discoverable
- NodePort: Expose on every node's port
- LoadBalancer: Cloud provider LB (external IP)

**Q: When do you use Ingress instead of LoadBalancer?**

A: Ingress is more efficient (single LB for all services) and supports hostname/path-based routing. LoadBalancer = one LB per service.

**Q: How do you debug network connectivity between pods?**

A:
- `kubectl exec -it pod -- sh` — Enter pod
- `wget http://service-name` — Test DNS
- `netstat -tlnp` — Check listening ports
- `kubectl describe service` — Check endpoints

### **6. Storage & Persistence**

**Q: What's the difference between ephemeral and persistent storage?**

A: Ephemeral = lost when pod restarts. Persistent = survives pod restarts (for databases, caches).

**Q: How do you use PersistentVolume/Claim?**

A: PV = cluster-level storage. PVC = pod's request for storage. Pod mounts PVC which binds to PV.

### **7. Observability**

**Q: What are the three pillars of observability?**

A: Metrics (what), Logs (why), Traces (how).

**Q: How do you query Prometheus metrics?**

A:
- `node_memory_MemFree_bytes` — Free memory
- `rate(container_cpu_usage_seconds_total[5m])` — CPU rate
- `histogram_quantile(0.95, request_duration_seconds_bucket)` — p95 latency

**Q: What alerts would you set up for an API?**

A:
- High error rate (> 1%)
- High latency (p95 > threshold)
- Pod restarts (frequent crashes)
- Node resources (CPU/memory near limits)

### **8. DevOps Practices**

**Q: What's the difference between CI and CD?**

A: CI = build + test every commit. CD = delivery (manual approval possible) or deployment (auto to production).

**Q: How do you implement blue-green deployments?**

A: Run two parallel environments. Route traffic to blue (current). Deploy to green, test, then switch traffic.

**Q: What's a canary deployment?**

A: Gradually shift traffic to new version (e.g., 10% → 50% → 100%). Monitor metrics at each step.

### **9. Security**

**Q: How do you manage secrets in Kubernetes?**

A: K8s Secrets (base64 encoded by default), Sealed Secrets (encrypted at rest), HashiCorp Vault (external vault).

**Q: What's a Network Policy?**

A: Restrict pod-to-pod communication. Default = all traffic allowed. Define rules for allowed traffic.

**Q: How do you prevent pods from running as root?**

A:
- Pod SecurityContext: `runAsNonRoot: true`
- Pod SecurityPolicy: enforce across namespace
- RBAC: restrict what pods can do

### **10. Troubleshooting**

**Q: Pod stuck in Pending state?**

A:
- `kubectl describe pod` — Check for scheduling errors
- `kubectl top nodes` — Check node resources
- Image pull failure? — Verify image exists in registry

**Q: Service endpoints not populating?**

A:
- Pods have correct labels? — Match service selector
- Pods running and healthy? — Check `kubectl get pods`
- Correct ports? — Match containerPort with service port

**Q: High latency or timeouts?**

A:
- Network policies blocking? — Check netpol rules
- Resource limits exceeded? — Check CPU/memory
- Application issue? — Check logs, traces

---

## Interview Formats

### **Format 1: Technical Deep-Dive**

Interviewer asks about specific experience:
- "Tell me about a time you debugged a production issue"
- "How did you handle a database migration?"
- "Describe your CI/CD pipeline"

**Answer Strategy:**
- STAR method (Situation, Task, Action, Result)
- Show problem-solving process
- Mention monitoring, alerts, rollback


### **Format 2: Architecture Design**

"Design deployment for high-traffic e-commerce site"

**Answer includes:**
- Multi-region setup for HA
- Caching layer (Redis)
- Database replication
- Load balancing strategy
- Monitoring/alerting
- Security (encryption, auth)
- Disaster recovery

### **Format 3: Problem-Solving**

"You deploy an update, traffic drops 50%. What do you do?"

**Answer includes:**
1. Immediate: Rollback (Helm: `rollback`, GitOps: revert commit)
2. Investigate: Check logs, metrics, recent changes
3. Communicate: Alert team, update status page
4. Prevent: Root cause analysis, add tests/monitoring

---

## Technical Assessment Topics

### **Hands-On Lab** (~1-2 hours)

Common scenarios:
- Deploy app to Kubernetes
- Fix broken YAML manifests
- Implement scaling policy
- Create Helm chart
- Debug pod issue
- Set up monitoring

**Preparation:**
- Practice all labs multiple times
- Hands-on with your own cluster
- Be comfortable with kubectl commands
- Understand what tools do, not just commands

### **Take-Home Assignment**

Common tasks:
- Design K8s manifests for app
- Create Helm chart
- Write CI/CD pipeline
- Deploy to cloud (AWS/GCP/Azure)
- Set up monitoring

**Tips:**
- Clean, readable YAML (proper formatting)
- Meaningful labels and naming
- Production-ready (resource limits, health checks, etc.)
- Document your choices
- Include README explaining deployment

---

## Salary & Career Path

### **DevOps Role Titles** (progression)

1. **Junior DevOps Engineer** (0-2 yrs)
   - Building CI/CD pipelines
   - Writing Infrastructure as Code
   - Container basics
   - Basic troubleshooting

2. **DevOps Engineer** (2-5 yrs)
   - Multi-region deployments
   - Kubernetes management
   - Monitoring & observability
   - Security & compliance

3. **Senior DevOps Engineer** (5+ yrs)
   - Architecture design
   - Mentoring team
   - Cost optimization
   - Strategy & planning

4. **Staff / Platform Engineer**
   - Platform design
   - Technical leadership
   - Innovation

### **Skills That Command Premium Pay**

- Multi-cloud (AWS, GCP, Azure)
- Kubernetes expertise
- Infrastructure as Code mastery
- Security & compliance
- Cost optimization
- FinOps knowledge
- Leadership & mentoring

---

## Final Tips

✅ **Practice hands-on** — Don't just watch videos  
✅ **Understand the "why"** — Not just "how" to run commands  
✅ **Communicate clearly** — Explain your thinking  
✅ **Ask clarifying questions** — Don't assume  
✅ **Admit what you don't know** — "I haven't used that, but I'd approach it by..."  
✅ **Stay current** — DevOps evolves, keep learning  

---

## Resources for Further Learning

- **Kubernetes**: https://kubernetes.io/docs/
- **Helm**: https://helm.sh/docs/
- **Flux**: https://fluxcd.io/flux/
- **Community**: DevOps subreddits, local meetups, Slack channels

---

**Good luck with your interviews!**

---

Use these to self-assess your DevOps knowledge or prepare for interviews.

## Tier 1: Fundamentals (Junior Level)

### Docker & Containerization

**Q1.1**: What is a Docker image vs. a container?

<details>
<summary>Answer</summary>

**Image**: A blueprint/template (immutable), like a class definition
**Container**: A running instance of an image (mutable), like an object

You can have one image and run 100 containers from it.
</details>

**Q1.2**: What does `docker build` do and what's the output?

<details>
<summary>Answer</summary>

Builds a Docker image from a Dockerfile. Process:
1. Reads Dockerfile instructions
2. Creates layers (for caching)
3. Stores image locally

Output: Docker image (tagged, e.g., myapp:1.0.0)
</details>

**Q1.3**: Explain Dockerfile layers and why caching matters

<details>
<summary>Answer</summary>

Each command in Dockerfile = one layer. Docker caches layers.

Example:
- Layer 1: FROM python:3.11 (200MB, cached)
- Layer 2: COPY requirements.txt (1MB, cached)
- Layer 3: RUN pip install (cached)
- Layer 4: COPY mycode.py (code changed, re-runs)
- Layer 5-end: Re-run

**Why it matters**: Only changed layers rebuild. Saves time.
</details>

### Kubernetes Fundamentals

**Q1.4**: What is a Pod?

<details>
<summary>Answer</summary>

Smallest unit in Kubernetes. Can contain 1+ containers (usually 1).

Containers in a pod:
- Share network namespace (same IP)
- Share storage volumes
- Can communicate via localhost

Pods are ephemeral (transient). Don't create directly; use Deployments.
</details>

**Q1.5**: What's the difference between Deployment and Pod?

<details>
<summary>Answer</summary>

**Pod**: Single instance (ephemeral)  
**Deployment**: Describes desired state (manage 1+ pods)

Deployment handles:
- Replication (run N copies)
- Restarting crashed pods
- Rolling updates
- Scaling

**Best practice**: Always use Deployment, never create Pods directly.
</details>

**Q1.6**: What does `kubectl apply` do?

<details>
<summary>Answer</summary>

Applies a manifest (YAML) to cluster.

If resource doesn't exist → creates it  
If resource exists → updates it  
If resource removed from manifest → deleted next time

**Idempotent**: Safe to run multiple times.
</details>

### Services & Networking

**Q1.7**: What are the three Service types?

<details>
<summary>Answer</summary>

1. **ClusterIP** (default): Internal communication only. DNS name: service-name.namespace.svc.cluster.local

2. **NodePort**: Expose on every node's IP:port. Accessible from outside cluster.

3. **LoadBalancer**: Cloud provider load balancer. Assigns external IP.

**When to use**:
- ClusterIP: Pod-to-pod communication
- NodePort: External access without cloud LB
- LoadBalancer: Production external access
</details>

---

## Tier 2: Intermediate (Mid-Level)

### Helm & Package Management

**Q2.1**: What is Helm and what problem does it solve?

<details>
<summary>Answer</summary>

Helm = "package manager for Kubernetes"

Solves:
- **Duplication**: Templating (values parameterize manifests)
- **Versioning**: Release management
- **Dependencies**: Chart dependencies
- **Upgrades**: Easy updates + rollbacks

Example: Instead of 10 YAML files, one Helm chart with values.
</details>

**Q2.2**: Explain `helm install` vs. `helm upgrade --install`

<details>
<summary>Answer</summary>

- **helm install**: Creates new release. Fails if release already exists.
- **helm upgrade --install**: Creates if missing, updates if exists.

**Best practice**: Use `--install` for idempotency.
</details>

**Q2.3**: How do you manage different environments (dev, staging, prod) with Helm?

<details>
<summary>Answer</summary>

Use multiple values files:

```bash
# Dev: 1 replica, small resources
helm install myapp ./chart -f values-dev.yaml

# Prod: 5 replicas, large resources
helm install myapp ./chart -f values-prod.yaml
```

Each file overrides defaults in values.yaml.
</details>

### Kubernetes Advanced

**Q2.4**: What's the difference between Deployment, StatefulSet, and DaemonSet?

<details>
<summary>Answer</summary>

| Type | Use | Pods |
|------|-----|------|
| **Deployment** | Stateless (APIs, web) | Interchangeable, random names |
| **StatefulSet** | Stateful (databases) | Unique identity (pod-0, pod-1), persistent storage |
| **DaemonSet** | Node-level (logging) | One per node, always |

**When to use**:
- Deployment: 99% of apps
- StatefulSet: PostgreSQL, MongoDB, Redis
- DaemonSet: Filebeat, node exporter, CNI
</details>

**Q2.5**: How does a rolling update work?

<details>
<summary>Answer</summary>

Kubernetes gradually replaces old pods with new ones:

1. Old version: 3 pods running v1.0
2. Spin up 1 pod v2.0 (4 total)
3. Remove 1 v1.0 (3 total)
4. Repeat until all v2.0

**Benefits**: Zero downtime, automatic rollback if health checks fail

**Controls**: maxSurge, maxUnavailable
</details>

**Q2.6**: What's a Persistent Volume and why do you need it?

<details>
<summary>Answer</summary>

**Problem**: Container storage is ephemeral. Pod restarts = data lost.

**Solution**: PersistentVolume + PersistentVolumeClaim

**PV** = cluster-level storage resource (10GB)  
**PVC** = Pod's request for storage ("I need 5GB")

Pod uses data that survives restarts.

**Use cases**: Databases, cached data, logs.
</details>

### Observability

**Q2.7**: What are the three pillars of observability?

<details>
<summary>Answer</summary>

1. **Metrics**: Numeric measurements (CPU, latency, error rate)  
   Tool: Prometheus

2. **Logs**: Discrete events with context  
   Tool: Loki

3. **Traces**: Request path across services  
   Tool: Jaeger

Together → complete visibility. Separately → blind spots.
</details>

**Q2.8**: How do you debug high latency in a Kubernetes service?

<details>
<summary>Answer</summary>

1. **Check metrics**: Prometheus latency queries
2. **Check logs**: Pod logs for errors
3. **Check traces**: Jaeger for service breakdown
4. **Check network**: Network policies, node CPU/memory
5. **Check application**: Profiling, database queries
</details>

---

## Tier 3: Advanced (Senior Level)

### GitOps & Infrastructure as Code

**Q3.1**: What is GitOps and how does Flux differ from Jenkins?

<details>
<summary>Answer</summary>

**GitOps**: Git = single source of truth. Automated agents reconcile cluster to match Git.

| Aspect | Jenkins (Push) | Flux (Pull) |
|--------|---|---|
| **Trigger** | Pipeline runs `helm upgrade` | Flux watches Git |
| **Drift** | No detection | Auto-corrects |
| **Audit** | Pipeline logs | Git commit history |
| **Rollback** | Rerun pipeline | `git revert` |

**Flux benefits**: Better drift detection, audit trail, easier rollback.
</details>

**Q3.2**: How do you implement multi-cluster GitOps?

<details>
<summary>Answer</summary>

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
</details>

**Q3.3**: Describe a canary deployment strategy

<details>
<summary>Answer</summary>

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
</details>

### Multi-Region & Advanced Patterns

**Q3.4**: How would you design a multi-region Kubernetes deployment?

<details>
<summary>Answer</summary>

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
</details>

**Q3.5**: What's a sidecar and when do you use it?

<details>
<summary>Answer</summary>

**Sidecar** = additional container in pod (shares network, storage)

**Use cases**:
1. **Logging**: Pod writes logs, sidecar ships to Loki
2. **Metrics**: Sidecar exposes metrics endpoint
3. **Network proxy**: Envoy intercepts traffic (encryption, rate limit, retries)
4. **Security**: Sidecar enforces auth/encryption

**Benefit**: Extend functionality without changing app code.
</details>

### Security & Compliance

**Q3.6**: How do you manage secrets in Kubernetes securely?

<details>
<summary>Answer</summary>

**Options** (from basic to advanced):

1. **K8s Secrets**: Base64 encoded (not encrypted by default) — OK for dev

2. **Encryption at rest**: Enable in etcd (API server config)

3. **Sealed Secrets**: Encrypt secrets using cluster public key

4. **External Vault**: HashiCorp Vault (external secret management)

5. **Secret operator**: Automatically rotates/syncs secrets

**Best practice**: Use sealed secrets or external vault for production.
</details>

**Q3.7**: What's Network Policy and how do you implement zero-trust?

<details>
<summary>Answer</summary>

**Network Policy**: Restrict pod-to-pod communication (like firewall)

```yaml
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
</details>

### Troubleshooting & Operations

**Q3.8**: Debug a production outage: "All requests returning 500 errors"

<details>
<summary>Answer</summary>

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
</details>

**Q3.9**: What's SLA/SLO/SLI and why important?

<details>
<summary>Answer</summary>

- **SLA** (Service Level Agreement): Contract with users (99.99% uptime)
- **SLO** (Service Level Objective): Internal goal (99.9% for us)
- **SLI** (Service Level Indicator): Actual measurement (99.87% actual)

**Error budget**: If SLO=99.9%, you can tolerate 0.1% errors.

**Why**: 
- SLOs drive reliability decisions
- Error budget prevents "always live" culture
- Balances speed and reliability
</details>

---

## Practical Scenarios

### Scenario 1: Design a Deployment

Design K8s + Helm setup for an API serving 10M requests/day

**Expected answer covers**:
- Deployment (3+ replicas, health checks)
- HPA (auto-scale on CPU/memory)
- Service (ClusterIP, internal)
- Ingress (external access, TLS)
- ConfigMap/Secrets (config, credentials)
- PVC (if stateful: database)
- NetworkPolicy (restrict traffic)
- Monitoring (Prometheus, alerts)
- GitOps (Flux/ArgoCD)

### Scenario 2: Incident Response

Production database is consuming 90% CPU. Users report slow queries.

**Answer should**:
- Identify root cause (query, missing index, traffic spike)
- Immediate mitigation (scale up, rate limit)
- Fix (optimize query, add index)
- Prevention (monitoring, alerting)
- Post-mortem (team learning)

### Scenario 3: Cost Optimization

K8s bill increased 3x. How do you reduce?

**Solutions**:
- Right-size resource requests/limits
- Use HPA instead of static scaling
- Spot instances for non-critical workloads
- Consolidate to fewer nodes
- Remove unused resources (old deployments)
- Use reserved instances for predictable load

---

## Scoring Guide

### How to Use These Questions

**Self-Assessment**:
- Tier 1 (Fundamentals): Should answer 90%+ fluently
- Tier 2 (Intermediate): Should answer 70%+ with some thought
- Tier 3 (Advanced): Should answer 50%+ (these are hard)

**Interview Prep**:
- Practice answering without looking up answers
- Time yourself (1-2 min per question)
- Record yourself explaining concepts
- Discuss with peers

**Success Metrics**:
- Tier 1: Mastery (can teach others)
- Tier 2: Competency (comfortable in mid-level role)
- Tier 3: Depth (ready for senior role)

---

## Final Tips

✅ **Understand the "why"** not just "how"  
✅ **Practice hands-on** — Theory alone isn't enough  
✅ **Explain clearly** — Communication is key  
✅ **Ask clarifying questions** — Don't assume  
✅ **Admit gaps** — "I don't know, but I'd approach it by..."  

**Good luck! 🚀**