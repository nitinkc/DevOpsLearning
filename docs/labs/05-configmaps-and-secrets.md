# Lab 05: ConfigMaps & Secrets

## Objectives

- ✅ Create ConfigMaps from files and literals
- ✅ Create Secrets for sensitive data
- ✅ Mount ConfigMaps as environment variables
- ✅ Mount Secrets as volumes
- ✅ Update configurations without redeploying

## Prerequisites

- Lab 04 complete
- ~1 hour

## Step 1: Create ConfigMap

```bash
# Create from literals
kubectl create configmap app-config \
  --from-literal=LOG_LEVEL=INFO \
  --from-literal=ENVIRONMENT=development \
  --from-literal=DATABASE_HOST=postgres.default.svc.cluster.local

# Verify
kubectl get configmap app-config
kubectl describe configmap app-config
```

## Step 2: Create Secret

```bash
# Create from literals
kubectl create secret generic app-secret \
  --from-literal=DB_PASSWORD=secretpassword123 \
  --from-literal=API_KEY=mysecretkey789

# Verify
kubectl get secret app-secret
kubectl describe secret app-secret

# Note: Secrets are base64 encoded, NOT encrypted by default
# In production, use Sealed Secrets or Vault
```

## Step 3: Use ConfigMap as Environment Variables

??? note "api-with-config.yaml"

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: api-with-config
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: api-config
      template:
        metadata:
          labels:
            app: api-config
        spec:
          containers:
          - name: api
            image: YOUR_USERNAME/myapp:1.0.0
            ports:
            - containerPort: 5000
            env:
            # From ConfigMap
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: LOG_LEVEL
            - name: ENVIRONMENT
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: ENVIRONMENT
            - name: DATABASE_HOST
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: DATABASE_HOST
            # From Secret
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: DB_PASSWORD
    ```

Deploy and verify:

```bash
kubectl apply -f api-with-config.yaml

# Check env variables in pod
kubectl exec <pod-name> -- env | grep LOG_LEVEL
# Should output: LOG_LEVEL=INFO
```

## Step 4: Mount ConfigMap as Volume

Create `app.conf`:

```
server:
  port: 5000
  debug: false
  
database:
  host: postgres
  port: 5432
```

Create ConfigMap from file:

```bash
kubectl create configmap app-config-file --from-file=app.conf

# Verify
kubectl get configmap app-config-file
kubectl describe configmap app-config-file
```

Use in Pod:

??? note "api-with-volume.yaml"

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: api-with-volume
    spec:
      containers:
      - name: api
        image: YOUR_USERNAME/myapp:1.0.0
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: app-config-file
    ```

Deploy and verify:

```bash
kubectl apply -f api-with-volume.yaml

# Check mounted file
kubectl exec api-with-volume -- cat /etc/config/app.conf
# Should show file contents
```

## Step 5: Update ConfigMap (Without Redeeploy)

```bash
# Edit ConfigMap
kubectl edit configmap app-config
# Change LOG_LEVEL from INFO to DEBUG

# Verify change
kubectl describe configmap app-config | grep LOG_LEVEL

# Pod will NOT auto-update environment variables
# (Only mounts as volume are auto-updated)

# To force pod restart:
kubectl rollout restart deployment/api-with-config

# Now new pods get new env vars
kubectl exec <new-pod-name> -- env | grep LOG_LEVEL
# Should show: LOG_LEVEL=DEBUG
```

## Validation

```bash
# ConfigMaps exist
kubectl get configmaps

# Secrets exist
kubectl get secrets

# Pods receive configuration
kubectl exec $(kubectl get pod -l app=api-config -o jsonpath='{.items[0].metadata.name}') -- env | grep LOG_LEVEL
# Returns: LOG_LEVEL=INFO

# Volumes are mounted
kubectl exec api-with-volume -- ls /etc/config
# Returns: app.conf
```

## Challenge (Optional)

Create Kustomization to manage multiple environments:

```bash
# Create patches for prod
mkdir -p kustomize/prod
cat > kustomize/prod/kustomization.yaml <<EOF
bases:
  - ../base

configMapGenerator:
- name: app-config
  literals:
  - LOG_LEVEL=ERROR
  - ENVIRONMENT=production
EOF

# Apply
kubectl apply -k kustomize/prod/
```

## Cleanup

```bash
kubectl delete deployment api-with-config api-with-volume
kubectl delete configmap app-config app-config-file
kubectl delete secret app-secret
```

---

**Next**: [Lab 06: Helm Charts](06-helm-charts.md)
