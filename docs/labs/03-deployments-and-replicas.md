# Lab 03: Deployments & Replicas

## Objectives

- ✅ Create Deployment manifests with replicas
- ✅ Scale replicas up and down
- ✅ Watch rolling updates in real-time
- ✅ Configure health checks (liveness/readiness)
- ✅ Rollback failed deployments
- ✅ Understand init containers

## Prerequisites

- Lab 02 complete
- Minikube running
- ~1.5 hours

## Step 1: Create Deployment Manifest

Create `api-deployment.yaml`:

??? note "api-deployment.yaml"

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: api-deployment
      labels:
        app: api
    spec:
      replicas: 3
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1        # Max extra pods during update
          maxUnavailable: 0  # Zero downtime requirement
      selector:
        matchLabels:
          app: api
      template:
        metadata:
          labels:
            app: api
        spec:
          containers:
          - name: api
            image: YOUR_USERNAME/myapp:1.0.0
            ports:
            - containerPort: 5000
            resources:
              requests:
                memory: "256Mi"
                cpu: "100m"
              limits:
                memory: "512Mi"
                cpu: "500m"
            livenessProbe:
              httpGet:
                path: /health
                port: 5000
              initialDelaySeconds: 10
              periodSeconds: 5
              failureThreshold: 3
            readinessProbe:
              httpGet:
                path: /ready
                port: 5000
              initialDelaySeconds: 5
              periodSeconds: 10
              failureThreshold: 1
    ```

## Step 2: Deploy & Verify

```bash
# Deploy
kubectl apply -f api-deployment.yaml

# brew install watch
# Watch replicas being created (in another terminal)
watch kubectl get pods -l app=api

# Verify all 3 running
kubectl get deployment api-deployment
# Expected: 3 desired, 3 current, 3 ready
```

## Step 3: Scale Replicas

```bash
# Scale up to 5
kubectl scale deployment api-deployment --replicas=5

# Watch pods launching
watch kubectl get pods

# Scale down to 2
kubectl scale deployment api-deployment --replicas=2

# Back to 3
kubectl scale deployment api-deployment --replicas=3
```

## Step 4: Rolling Update

```bash
# Update image (simulate new version)
kubectl set image deployment/api-deployment api=YOUR_USERNAME/myapp:2.0.0

# Watch rolling update in progress
watch kubectl rollout status deployment/api-deployment

# View rollout history
kubectl rollout history deployment/api-deployment
```

## Step 5: Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/api-deployment

# Verify pods are back to v1.0.0
kubectl get pods -l app=api -o jsonpath='{.items[*].spec.containers[0].image}'

# View revision history
kubectl rollout history deployment/api-deployment --revision=1
kubectl rollout history deployment/api-deployment --revision=2
```

## Validation

```bash
# Deployment is running with 3 replicas
kubectl get deployment api-deployment
# DESIRED: 3, CURRENT: 3, READY: 3

# All pods are healthy
kubectl get pods -l app=api
# All STATUS: Running

# Health checks pass
kubectl describe pod <any-pod-name> | grep -A3 "Liveness\|Readiness"
```

## Challenge (Optional)

Implement HPA (Horizontal Pod Autoscaler):

??? note "api-hpa.yaml"

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: api-hpa
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: api-deployment
      minReplicas: 3
      maxReplicas: 10
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 70
    ```

# Apply the commands to create the HPA and monitor it:

```shell
kubectl apply -f api-hpa.yaml
kubectl get hpa
kubectl describe hpa api-hpa
```

## Cleanup

```bash
kubectl delete deployment api-deployment
kubectl delete hpa api-hpa 2>/dev/null || true
```

---

**Next**: [Lab 04: Services & Discovery](04-services-and-discovery.md)
