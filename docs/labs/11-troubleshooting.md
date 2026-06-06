# Lab 11: Troubleshooting

## Objectives

- ✅ Debug pod failures (CrashLoopBackOff, Pending, etc.)
- ✅ Inspect events and logs
- ✅ Network debugging (DNS, connectivity)
- ✅ Performance troubleshooting
- ✅ Use kubectl tools effectively

## Prerequisites

- All previous labs complete
- ~2 hours

## Scenario 1: Pod in Pending State

Create broken deployment:

??? note "YAML example"

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: broken-pending
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: broken
      template:
        metadata:
          labels:
            app: broken
        spec:
          containers:
          - name: app
            image: nonexistent/image:v999
            resources:
              requests:
                memory: "50Gi"  # Impossible to allocate
                cpu: "100"
    ```

Deploy and diagnose:

```bash
kubectl apply -f broken-pending.yaml

# Check pod status
kubectl get pods -l app=broken
# STATUS: Pending

# Debug steps
kubectl describe pod <pod-name>
# Look for: Events section

# Output will show:
# "Insufficient memory" or "Unschedulable"

# Check node resources
kubectl describe nodes
# See available memory/CPU

# Check events cluster-wide
kubectl get events --all-namespaces

# Fix: Reduce resource requests
kubectl patch deployment broken-pending -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"requests":{"memory":"256Mi","cpu":"100m"}}}]}}}}'

# Pod should start
watch kubectl get pods -l app=broken
```

## Scenario 2: CrashLoopBackOff

Create app that crashes:

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: crashloop-app
    spec:
      containers:
      - name: app
        image: busybox
        command:
        - /bin/sh
        - -c
        - |
          echo "App starting"
          exit 1  # Immediate exit = crash
      restartPolicy: Always
    ```

Deploy and debug:

```bash
kubectl apply -f crashloop-app.yaml

# Check status
kubectl get pods crashloop-app -w
# STATUS: CrashLoopBackOff

# View logs
kubectl logs crashloop-app
# Shows: "App starting" then exit

# View all logs (including old restarts)
kubectl logs crashloop-app --previous

# Check restart count
kubectl describe pod crashloop-app
# Shows: Restart Count: 5, Last State: Terminated (exit code 1)

# Fix: Make app not crash
kubectl delete pod crashloop-app

# Edit and redeploy with proper command
```

## Scenario 3: Image Pull Failure

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: imagepull-failed
spec:
  containers:
  - name: app
    image: private.registry.com/secret:v1
    # No credentials provided
```

Debug:

```bash
kubectl apply -f imagepull-failed.yaml

# Check status
kubectl get pods imagepull-failed
# STATUS: ImagePullBackOff

# View events
kubectl describe pod imagepull-failed
# Shows: Failed to pull image "private.registry.com/..."
# Error: image pull secrets not configured

# Fix: Create imagePullSecret
kubectl create secret docker-registry regcred \
  --docker-server=private.registry.com \
  --docker-username=user \
  --docker-password=pass

# Add to pod
kubectl patch serviceaccount default \
  -p '{"imagePullSecrets":[{"name":"regcred"}]}'
```

## Scenario 4: Service Not Routing Traffic

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: broken-service
    spec:
      ports:
      - port: 80
        targetPort: 5000
      selector:
        app: api-wrong-label  # Doesn't match pod
    
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: api-pod
      labels:
        app: api-correct-label  # Different label
    spec:
      containers:
      - name: app
        image: YOUR_USERNAME/myapp:1.0.0
        ports:
        - containerPort: 5000
    ```

Debug:

```bash
kubectl apply -f broken-service.yaml

# Check service
kubectl get svc broken-service

# Check endpoints (should be empty)
kubectl get endpoints broken-service
# ENDPOINTS: <none>  ← Problem!

# Diagnose: Check service selector
kubectl describe svc broken-service
# Selectors: app=api-wrong-label

# Check pod labels
kubectl get pods --show-labels
# api-pod has label: app=api-correct-label

# They don't match! Fix the service selector
kubectl patch svc broken-service \
  -p '{"spec":{"selector":{"app":"api-correct-label"}}}'

# Endpoints should now populate
kubectl get endpoints broken-service
# ENDPOINTS: 10.x.x.x:5000
```

## Scenario 5: Network Connectivity Issues

Test connectivity:

```bash
# Deploy two pods
kubectl run pod1 --image=curlimages/curl --rm -it -- /bin/sh
# Inside: curl http://pod2-ip:5000

# Check if DNS works
kubectl run test --image=curlimages/curl --rm -it -- \
  curl http://broken-service
# If fails: DNS issue

# Debug DNS
kubectl run -it --image=busybox --restart=Never debug -- nslookup broken-service
# If fails: CoreDNS issue

# Check network policies
kubectl get networkpolicy
# May be blocking traffic

# Test without network policy
kubectl delete networkpolicy --all

# Retest connectivity
```

## Scenario 6: Resource Exhaustion

Simulate high CPU:

```bash
# Create pod that uses CPU
kubectl run stress --image=polinux/stress -- stress --cpu 4

# Monitor
watch kubectl top pods

# Or check metrics
curl http://prometheus:9090/api/v1/query?query=rate\(container_cpu_usage_seconds_total\[5m\]\)

# If pod OOMKilled:
kubectl describe pod stress
# Last State: Terminated (OOMKilled)

# Check limits
kubectl get pod stress -o jsonpath='{.spec.containers[0].resources}'

# Fix: Increase limits
kubectl set resources deployment stress \
  --limits=cpu=2,memory=1Gi
```

## Scenario 7: Configuration Errors

ConfigMap/Secret not found:

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: config-error
    spec:
      containers:
      - name: app
        image: YOUR_USERNAME/myapp:1.0.0
        env:
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret  # Doesn't exist
              key: password
    ```

Debug:

```bash
kubectl apply -f config-error.yaml

# Pod may fail to start
kubectl describe pod config-error
# Events: secret "db-secret" not found

# Create missing secret
kubectl create secret generic db-secret \
  --from-literal=password=mysecret

# Restart pod
kubectl delete pod config-error
kubectl apply -f config-error.yaml
```

## Scenario 8: Using Tools Effectively

Key debugging commands:

```bash
# Comprehensive pod info
kubectl describe pod <name>

# Live logs
kubectl logs -f <pod>

# Previous logs (if crashed)
kubectl logs <pod> --previous

# All events
kubectl get events --sort-by='.lastTimestamp'

# Pod resource usage
kubectl top pod

# Node resource usage
kubectl top nodes

# Pod YAML
kubectl get pod <name> -o yaml

# Detailed pod state
kubectl get pod <name> -o wide

# Execute command in pod
kubectl exec -it <pod> -- /bin/sh

# Port-forward for debugging
kubectl port-forward <pod> 8000:5000

# Watch pods
watch kubectl get pods

# Real-time events
kubectl get events -w
```

## Validation

Successfully debug all scenarios:

1. Fix Pending pod (reduce resource requests)
2. Fix CrashLoopBackOff (make app not crash)
3. Fix ImagePull failure (add image pull secret)
4. Fix Service routing (fix selector labels)
5. Fix Network connectivity (check DNS, remove network policies)
6. Fix Resource exhaustion (increase limits)
7. Fix Configuration errors (create missing secrets)

## Challenge (Optional)

Create a multi-failure scenario:

```yaml
# Deployment with multiple issues:
# - Wrong image tag
# - Missing ConfigMap
# - Resource limits too low
# - Wrong service selector
```

Task: Identify and fix all issues using kubectl tools.

## Cleanup

```bash
kubectl delete pod/crashloop-app
kubectl delete pod/imagepull-failed
kubectl delete pod/config-error
kubectl delete deployment/broken-pending
kubectl delete deployment/stress
kubectl delete svc/broken-service
```

---

**Congratulations!** You've completed all 11 labs and mastered DevOps from Docker to troubleshooting! 🎉

**Next Steps:**
- Review [Interview Prep](../docs/interview-prep.md)
- Practice with [Interview Questions](../docs/interview-questions.md)
- Build your own multi-cluster deployment
- Teach these concepts to others
