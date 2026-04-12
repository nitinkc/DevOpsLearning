# 06: Helm — Package Management

## Definition

**Helm** = Package manager for Kubernetes (like apt, brew for K8s).

Think of it as:
- **Templating**: Parameterize K8s manifests
- **Packaging**: Bundle manifests + values + dependencies
- **Versioning**: Track releases, easy rollback

---

## Helm Chart Structure

```
my-microservices-chart/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values
├── values-prod.yaml        # Production overrides
├── values-dev.yaml         # Dev overrides
├── templates/
│   ├── deployment.yaml     # Uses {{ .Values.* }} templates
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── hpa.yaml            # Horizontal Pod Autoscaler
│   └── _helpers.tpl        # Reusable helpers
├── requirements.yaml       # (v2) Chart dependencies
├── Chart.lock              # Locked dependency versions
└── README.md
```

### **Chart.yaml**

```yaml
apiVersion: v2
name: my-microservices
description: A Helm chart for microservices
type: application
version: 1.2.3
appVersion: "1.0.0"
keywords:
  - microservices
  - api
maintainers:
  - name: DevOps Team
    email: devops@example.com
```

### **values.yaml (Configuration)**

```yaml
replicaCount: 3

image:
  repository: myapp
  tag: "1.0.0"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 5000

ingress:
  enabled: true
  host: api.example.com
  path: /
  tls: true

resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

---

## Templating

### **deployment.yaml (Template)**

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
        resources:
          requests:
            memory: "{{ .Values.resources.requests.memory }}"
            cpu: "{{ .Values.resources.requests.cpu }}"
          limits:
            memory: "{{ .Values.resources.limits.memory }}"
            cpu: "{{ .Values.resources.limits.cpu }}"
        {{- if .Values.livenessProbe }}
        livenessProbe:
          httpGet:
            path: {{ .Values.livenessProbe.path }}
            port: {{ .Values.service.targetPort }}
        {{- end }}
```

**Variables available:**
- `{{ .Release.Name }}` — Release name (from `helm install`)
- `{{ .Chart.Name }}` — Chart name
- `{{ .Chart.Version }}` — Chart version
- `{{ .Values.* }}` — From values.yaml

### **Conditional Logic**

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-ingress
spec:
  rules:
  - host: {{ .Values.ingress.host }}
    http:
      paths:
      - path: {{ .Values.ingress.path }}
{{- end }}
```

---

## Installing & Managing Charts

```bash
# Add a Helm repository
helm repo add myrepo https://charts.example.com
helm repo update

# List available charts
helm search repo myrepo

# Install a chart
helm install my-app ./my-microservices-chart
  # Creates release "my-app"

# Install with custom values
helm install my-app ./chart -f values-prod.yaml
helm install my-app ./chart --set replicaCount=5 --set image.tag=2.0.0

# Install to specific namespace
helm install my-app ./chart -n production

# List releases
helm list
helm list -n production

# Get release values
helm get values my-app

# Get generated manifests (before applying)
helm template my-app ./chart

# Upgrade a release
helm upgrade my-app ./chart --set image.tag=2.0.0

# Rollback to previous release
helm rollback my-app
helm rollback my-app 1  # Specific revision

# View release history
helm history my-app

# Uninstall release
helm uninstall my-app
```

---

## Chart Dependencies

```yaml
# Chart.yaml
dependencies:
- name: postgres
  version: "14.x"
  repository: https://charts.bitnami.com/bitnami
  
- name: redis
  version: "18.x"
  repository: https://charts.bitnami.com/bitnami
  condition: redis.enabled  # Only install if redis.enabled=true
```

**Install dependencies:**

```bash
helm dependency update ./my-chart
# Downloads dependencies into charts/ directory
# Creates Chart.lock with exact versions
```

**values.yaml:**

```yaml
postgres:
  auth:
    username: myuser
    password: mypass
  enabled: true

redis:
  enabled: false  # Don't install redis
```

---

## Hooks (Lifecycle)**

Run containers at specific points (after install, before upgrade, etc.).

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-db-migration"
  annotations:
    "helm.sh/hook": pre-upgrade  # Run before upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    spec:
      containers:
      - name: db-migration
        image: myapp:{{ .Values.image.tag }}
        command: ["python", "manage.py", "migrate"]
      restartPolicy: Never
```

**Hook Types:**
- `pre-install` — Before install
- `post-install` — After install
- `pre-upgrade` — Before upgrade
- `post-upgrade` — After upgrade
- `pre-delete` — Before uninstall
- `post-delete` — After uninstall

---

## Environment-Specific Values

```bash
# development
helm install my-app ./chart -f values-dev.yaml

# staging
helm install my-app ./chart -f values-staging.yaml

# production
helm install my-app ./chart -f values-prod.yaml
```

Each environment file overrides defaults:

**values-prod.yaml:**
```yaml
replicaCount: 10  # More replicas

image:
  tag: "1.0.0"

autoscaling:
  maxReplicas: 30  # Higher max

resources:
  requests:
    memory: "512Mi"
    cpu: "200m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

---

## Best Practices

✅ **Always use specific chart versions**
```bash
helm install my-app myrepo/mychart --version 1.2.3
```

✅ **Use `helm template` to validate before install**
```bash
helm template my-app ./chart | kubectl apply --dry-run=client -f -
```

✅ **Keep values organized by environment**
```
values.yaml (defaults)
values-dev.yaml (dev overrides)
values-prod.yaml (prod overrides)
```

✅ **Use conditions for optional components**
```yaml
{{- if .Values.monitoring.enabled }}
apiVersion: v1
kind: Service...
{{- end }}
```

---

## Interview Questions

**Q: What's the difference between `helm install` and `helm upgrade --install`?**

A: `install` fails if release exists. `upgrade --install` installs if absent, upgrades if exists.

**Q: How do you roll back a Helm release?**

A: `helm rollback <release-name>` reverts to previous version. `helm rollback <release-name> <revision>` reverts to specific version.

**Q: Why use Helm instead of raw Kubernetes manifests?**

A: Templating (remove duplication), packaging, dependency management, versioning, easy upgrades/rollbacks.

---

## Key Takeaways

✅ **Helm reduces manifest duplication via templating**  
✅ **Charts include templates, values, dependencies**  
✅ **Values files enable environment-specific configuration**  
✅ **`helm upgrade --install` for idempotent deployments**  
✅ **Hooks automate tasks (DB migrations, etc.)**  
✅ **Rollback is one command**  

---

## Next Steps

- **Read**: [Theory 07: GitOps & Flux](07-gitops-and-flux.md)
- **Do**: [Lab 06: Helm Charts](../labs/06-helm-charts.md)
