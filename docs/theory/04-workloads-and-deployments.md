# 04: Workloads & Deployments

## Workload Types

Different K8s resources for different workload types:

| Workload | Use Case | Example |
|----------|----------|---------|
| **Deployment** | Stateless app, scale replicas | Web API, frontend |
| **StatefulSet** | Stateful app, stable identity | Database, message queue |
| **DaemonSet** | Run on every node | Logging agent, monitoring |
| **Job** | Run once to completion | Database migration, backup |
| **CronJob** | Scheduled task | Cleanup job every night |

---

## Deployments (Stateless Apps)

**Deployment** = manage stateless application replicas.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max extra pod during update
      maxUnavailable: 0  # Min pods available (zero downtime)
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api
        image: myapp:1.0.0
        ports:
        - containerPort: 5000
        livenessProbe:
          httpGet:
            path: /alive
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### **Rolling Updates**

Update image with zero downtime:

```bash
# Update image
kubectl set image deployment/api-server api=myapp:2.0.0

# Or use kubectl patch
kubectl patch deployment api-server -p '{"spec":{"template":{"spec":{"containers":[{"name":"api","image":"myapp:2.0.0"}]}}}}'

# Or edit declaratively
kubectl edit deployment api-server  # Update in editor
```

**What happens internally:**
```
Old: 3 pods running v1.0.0
Step 1: Spin up 1 pod v2.0.0 (4 total)
Step 2: Remove 1 v1.0.0 pod (3 total)
Step 3: Spin up 1 v2.0.0 (4 total)
Step 4: Remove 1 v1.0.0 (3 total)
...continue until all v2.0.0
Result: Zero downtime deployment
```

**Rollback if something goes wrong:**

```bash
kubectl rollout history deployment/api-server
kubectl rollout undo deployment/api-server  # Back to previous
kubectl rollout undo deployment/api-server --to-revision=2
```

---

## StatefulSets (Stateful Apps)

For applications that need:

- Stable, unique network identity (pod-0, pod-1, pod-2)
- Persistent storage
- Ordered startup/shutdown

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres  # Required
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:  # Auto-create persistent volumes
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

### **Key Differences**

| Deployment | StatefulSet |
|-----------|------------|
| Replicas are interchangeable | Each pod has unique identity (pod-0, pod-1) |
| Random pod names | Predictable pod names |
| No persistent storage | Persistent storage per pod |
| Scales up/down any order | Ordered startup/shutdown |
| Great for: APIs, webservers | Great for: Databases, caches, queues |

---

## DaemonSets (Node-Level Jobs)

Run a pod on **every node** in cluster.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: filebeat
spec:
  selector:
    matchLabels:
      app: filebeat
  template:
    metadata:
      labels:
        app: filebeat
    spec:
      containers:
      - name: filebeat
        image: docker.elastic.co/beats/filebeat:8.0.0
        volumeMounts:
        - name: logs
          mountPath: /var/log
      volumes:
      - name: logs
        hostPath:
          path: /var/log
```

**Use cases:**

- Logging agent (fluentd, logstash, filebeat)
- Monitoring agent (prometheus node exporter)
- Network plugin (CNI)

---

## Jobs & CronJobs (One-Time Tasks)

### **Job**

Run task to completion (don't restart).

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: database-migration
spec:
  template:
    spec:
      containers:
      - name: migration
        image: myapp:1.0.0
        command:
        - /bin/sh
        - -c
        - |
          python manage.py migrate
          python manage.py seed_data
      restartPolicy: Never
  backoffLimit: 3  # Retry 3 times before failing
```

### **CronJob**

Schedule job to run periodically.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-backup
spec:
  schedule: "0 2 * * *"  # 2 AM every day
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: myapp:1.0.0
            command:
            - /bin/sh
            - -c
            - |
              mysqldump -u root -p$MYSQL_PASSWORD mydb > /backup/db.sql
          restartPolicy: OnFailure
```

---

## Init Containers

Run setup containers **before** main application container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command: ['sh', '-c', "until nc -z postgres 5432; do echo waiting for DB; sleep 2; done"]
  
  containers:
  - name: app
    image: myapp:1.0.0
```

**Flow:**

1. Start init container (wait-for-db)
2. If init completes successfully → start main container
3. If init fails → restart pod

---

## Pod Disruption Budgets (PDB)

Prevent too many pods from being disrupted during maintenance.

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-pdb
spec:
  minAvailable: 2  # Always keep at least 2 running
  selector:
    matchLabels:
      app: api
```

When nodes are drained (maintenance), K8s respects PDB and doesn't take down more than allowed.

---

## Anti-Patterns

### ❌ **Single Replica**

```yaml
replicas: 1  # If pod crashes, app is down!
```

✅ **Always use multiple replicas**

```yaml
replicas: 3  # Pods protect against failure
```

### ❌ **No Health Checks**

K8s doesn't know if app crashed

✅ **Always use liveness and readiness probes**

### ❌ **No Resource Requests/Limits**

Pods can consume all node resources

✅ **Define requests and limits**

### ❌ **Creating Pods Directly**

```bash
kubectl run myapp --image=myapp:1.0.0  # Direct pod, no management
```

✅ **Use Deployments**

---

## Interview Questions

**Q: When do you use Deployment vs. StatefulSet?**

A: **Deployment** for stateless apps (APIs, frontends) — replicas are interchangeable. **StatefulSet** for stateful apps (databases, queues) — each pod has unique identity and persistent storage.

**Q: What happens during a rolling update?**

A: K8s gradually spins up new pod replicas and removes old ones, ensuring zero downtime (respects maxSurge and maxUnavailable).

**Q: What's an init container?**

A: Setup container that runs before main app container. Useful for waiting for dependencies (database) or setup tasks.

---

## Key Takeaways

✅ **Deployment for stateless apps (most common)**  
✅ **StatefulSet for stateful apps with persistent storage**  
✅ **DaemonSet to run on every node**  
✅ **Job for one-time tasks, CronJob for scheduled**  
✅ **Init containers for setup before main app**  
✅ **Always use multiple replicas for HA**  
✅ **Rolling updates = zero downtime deployments**  

---

## Next Steps

- **Read**: [Theory 05: Networking & Storage](05-networking-and-storage.md)
- **Do**: [Lab 03: Deployments & Replicas](../labs/03-deployments-and-replicas.md)
