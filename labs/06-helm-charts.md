# Lab 06: Helm Charts

## Objectives

- ✅ Understand Helm chart structure
- ✅ Create a Helm chart from scratch
- ✅ Template values and iterate through loops
- ✅ Deploy with Helm
- ✅ Upgrade and rollback releases
- ✅ Manage dependencies

## Prerequisites

- Lab 05 complete
- Helm CLI installed
- ~2 hours

## Step 1: Create Chart from Scratch

```bash
# Create new chart
helm create myapp-chart

# Explore structure
cd myapp-chart
tree
# Should show:
# ├── Chart.yaml
# ├── values.yaml
# ├── templates/
# │   ├── deployment.yaml
# │   ├── service.yaml
# │   └── ...
```

## Step 2: Edit Chart Metadata

Edit `Chart.yaml`:

??? note "YAML example"

    ```yaml
    apiVersion: v2
    name: myapp
    description: Sample app for learning Helm
    type: application
    version: 1.0.0
    appVersion: "1.0.0"
    keywords:
      - microservices
      - kubernetes
      - helm
    maintainers:
      - name: DevOps Team
        email: devops@example.com
    ```

## Step 3: Customize values.yaml

Edit `values.yaml`:

??? note "YAML example"

    ```yaml
    replicaCount: 3
    
    image:
      repository: YOUR_USERNAME/myapp
      tag: "1.0.0"
      pullPolicy: IfNotPresent
    
    service:
      type: ClusterIP
      port: 80
      targetPort: 5000
    
    ingress:
      enabled: false
    
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
    
    autoscaling:
      enabled: false
      minReplicas: 3
      maxReplicas: 10
      targetCPUUtilizationPercentage: 70
    
    config:
      logLevel: INFO
      environment: development
    ```

## Step 4: Template deployment.yaml

Edit `templates/deployment.yaml`:

??? note "YAML example"

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ .Release.Name }}-api
      labels:
        app: {{ .Chart.Name }}
        version: {{ .Chart.Version }}
    spec:
      replicas: {{ .Values.replicaCount }}
      selector:
        matchLabels:
          app: {{ .Chart.Name }}
      template:
        metadata:
          labels:
            app: {{ .Chart.Name }}
        spec:
          containers:
          - name: api
            image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            ports:
            - containerPort: {{ .Values.service.targetPort }}
            env:
            - name: LOG_LEVEL
              value: {{ .Values.config.logLevel }}
            - name: ENVIRONMENT
              value: {{ .Values.config.environment }}
            resources:
              requests:
                memory: "{{ .Values.resources.requests.memory }}"
                cpu: "{{ .Values.resources.requests.cpu }}"
              limits:
                memory: "{{ .Values.resources.limits.memory }}"
                cpu: "{{ .Values.resources.limits.cpu }}"
            livenessProbe:
              httpGet:
                path: /health
                port: {{ .Values.service.targetPort }}
              initialDelaySeconds: 10
              periodSeconds: 5
            readinessProbe:
              httpGet:
                path: /ready
                port: {{ .Values.service.targetPort }}
              initialDelaySeconds: 5
              periodSeconds: 10
    ```

## Step 5: Template service.yaml

Edit `templates/service.yaml`:

??? note "YAML example"

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: {{ .Release.Name }}-api
    spec:
      type: {{ .Values.service.type }}
      selector:
        app: {{ .Chart.Name }}
      ports:
      - protocol: TCP
        port: {{ .Values.service.port }}
        targetPort: {{ .Values.service.targetPort }}
    ```

## Step 6: Template YAML Preview

```bash
# See generated manifests before deploying
helm template myapp-release ./myapp-chart

# Validate syntax
helm lint ./myapp-chart
# Should show: 1 chart(s) linted, 0 error(s)
```

## Step 7: Install Release

```bash
# Install with default values
helm install my-app ./myapp-chart

# Or with overrides
helm install my-app ./myapp-chart \
  --set replicaCount=5 \
  --set image.tag=2.0.0

# List releases
helm list

# Get release values
helm get values my-app

# Get generated manifests
helm get manifest my-app
```

## Step 8: Upgrade Release

```bash
# Update image version
helm upgrade my-app ./myapp-chart --set image.tag=2.0.0

# Check status
helm status my-app

# View release history
helm history my-app
```

## Step 9: Rollback Release

```bash
# Rollback to previous version
helm rollback my-app

# Or to specific revision
helm rollback my-app 1

# Verify
helm status my-app
```

## Step 10: Environment-Specific Values

Create `values-prod.yaml`:

??? note "values-prod.yaml"

    ```yaml
    replicaCount: 10
    
    image:
      tag: "1.0.0"
    
    resources:
      requests:
        memory: "512Mi"
        cpu: "200m"
      limits:
        memory: "1Gi"
        cpu: "1000m"
    
    autoscaling:
      enabled: true
      maxReplicas: 30
    
    config:
      logLevel: ERROR
      environment: production
    ```

Deploy with prod values:

```bash
helm install my-app ./myapp-chart -f values-prod.yaml

# Verify
kubectl get deployment my-app-api
# Should have 10 replicas
```

## Validation

```bash
# Release exists and is deployed
helm list
# my-app should be DEPLOYED

# Pods running with correct image
kubectl get pods -o jsonpath='{.items[*].spec.containers[0].image}'
# Should show YOUR_USERNAME/myapp:1.0.0

# Service created
kubectl get svc my-app-api

# Upgrade worked
helm history my-app
# Should show multiple revisions
```

## Challenge (Optional)

Add chart dependencies:

Create `requirements.yaml` (Helm 2) or `Chart.yaml` (Helm 3):

```yaml
dependencies:
- name: postgresql
  version: "11.x.x"
  repository: https://charts.bitnami.com/bitnami
  condition: postgresql.enabled
```

```bash
# Update dependencies
helm dependency update ./myapp-chart

# Now your chart includes PostgreSQL
helm install my-app ./myapp-chart \
  --set postgresql.enabled=true \
  --set postgresql.auth.password=mysecret
```

## Cleanup

```bash
helm uninstall my-app
rm -rf myapp-chart/
```

---

**Next**: [Lab 07: Multi-Region Setup](07-multi-region-setup.md)
