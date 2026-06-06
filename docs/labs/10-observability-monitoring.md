# Lab 10: Observability & Monitoring

## Objectives

- ✅ Deploy Prometheus (metrics collection)
- ✅ Deploy Grafana (dashboards)
- ✅ Deploy Loki (log aggregation)
- ✅ Query metrics with PromQL
- ✅ Create custom dashboards
- ✅ Set up alerting rules

## Prerequisites

- Lab 09 complete
- Helm configured
- ~2 hours

## Step 1: Deploy Prometheus

Add Prometheus Helm repo:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Create `prometheus-values.yaml`:

??? note "prometheus-values.yaml"

    ```yaml
    prometheus:
      prometheusSpec:
        retention: 7d
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        
        # Scrape Kubernetes components
        serviceMonitorSelectorNilUsesHelmValues: false
        
    grafana:
      enabled: true
      adminPassword: admin123
    
    alertmanager:
      enabled: true
    ```

Install:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  -f prometheus-values.yaml \
  -n monitoring \
  --create-namespace

# Verify
kubectl get pods -n monitoring

# Port-forward to Prometheus
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090 &

# Port-forward to Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &
```

## Step 2: Access Grafana

Open browser:
- Grafana: http://localhost:3000
- Username: admin
- Password: admin123

Add Prometheus datasource:

1. Go to Configuration → Data Sources
2. Click "Add Data Source"
3. Select Prometheus
4. URL: http://prometheus-operated:9090
5. Click "Save & Test"

## Step 3: Create Custom Dashboard

```bash
# Check available metrics
curl http://localhost:9090/api/v1/query?query=up

# Query CPU usage
curl http://localhost:9090/api/v1/query?query=rate\(container_cpu_usage_seconds_total\[5m\]\)

```

In Grafana:

1. Create new Dashboard
2. Add Panel
3. Query: `rate(container_cpu_usage_seconds_total[5m])`
4. Format: Graph
5. Title: "CPU Usage"

## Step 4: Deploy Loki for Logs

Add Loki repo:

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

Install Loki:

```bash
helm install loki grafana/loki-stack \
  -n monitoring \
  --set promtail.enabled=true \
  --set prometheus.enabled=false

# Verify
kubectl get pods -n monitoring | grep loki

```

Add Loki datasource to Grafana:

1. Configuration → Data Sources
2. Add Data Source
3. Select Loki
4. URL: http://loki:3100

## Step 5: Query Logs in Grafana

Create new dashboard panel:

1. Add Panel → Logs
2. Query: `{namespace="default"}`
3. Run query

View logs:

```
# Direct query to Loki
curl "http://localhost:3100/loki/api/v1/query?query=%7Bnamespace%3D%22default%22%7D"
```

## Step 6: Create Alert Rules

Create `alert-rules.yaml`:

??? note "alert-rules.yaml"

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: prometheus-alerts
      namespace: monitoring
    data:
      alerts.yml: |
        groups:
        - name: kubernetes.rules
          interval: 30s
          rules:
          - alert: HighCPUUsage
            expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
            for: 5m
            annotations:
              summary: "High CPU usage detected"
              description: "Pod {{ $labels.pod }} CPU > 80%"
          
          - alert: HighMemoryUsage
            expr: container_memory_usage_bytes / 1073741824 > 0.8
            for: 5m
            annotations:
              summary: "High memory usage"
              description: "Pod {{ $labels.pod }} memory > 800MB"
          
          - alert: PodRestarts
            expr: increase(kube_pod_container_status_restarts_total[1h]) > 3
            annotations:
              summary: "Pod restarting frequently"
              description: "Pod {{ $labels.pod }} restarted {{ $value }} times in 1h"
    ```

Apply:

```bash
kubectl apply -f alert-rules.yaml

# Reload Prometheus
kubectl rollout restart -n monitoring deployment/prometheus-operator
```

## Step 7: Monitor Your Application

Deploy test app with metrics:

```bash
kubectl deploy myapp --image=YOUR_USERNAME/myapp:1.0.0 -n default

# Wait for metrics to be scraped (~1-2 min)

# Query app metrics
curl http://localhost:9090/api/v1/query?query=myapp_requests_total
```

## Step 8: Dashboard Best Practices

Create comprehensive dashboard:


```
Row 1: Infrastructure
  - Node CPU Usage (graph)
  - Node Memory Usage (graph)
  - Pod Count (gauge)

Row 2: Application
  - Request Rate (graph)
  - Request Latency p95 (graph)
  - Error Rate (graph)

Row 3: System Health
  - Pod Restart Count (table)
  - Node Status (stat)
  - Disk Usage (gauge)
```

Steps:

1. Create new dashboard
2. Add rows
3. Add panels with queries from above
4. Customize colors, thresholds, aliases
5. Save dashboard

## Step 9: Log Analysis

Query patterns in Loki:

```logql
# All errors
{namespace="default"} |= "ERROR"

# Logs from specific pod
{pod="myapp-*"}

# Error count over time
{namespace="default"} |= "ERROR" | rate(__error__ [5m])
```

## Validation

```bash
# Prometheus scraping metrics
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
curl http://localhost:9090/api/v1/query?query=up
# Should return series

# Grafana dashboards accessible
# http://localhost:3000 (login: admin/admin123)

# Alerts configured
kubectl get configmap -n monitoring
# prometheus-alerts exists

# Loki collecting logs
kubectl logs -f -n monitoring deployment/loki
```

## Challenge (Optional)

Implement custom metrics in your app:


```python
from prometheus_client import Counter, Histogram

request_count = Counter('myapp_requests_total', 'Total requests')
request_duration = Histogram('myapp_request_duration_seconds', 'Request duration')

@app.route('/api/data')
def data():
    request_count.inc()
    with request_duration.time():
        # Do work
        return data
    
@app.route('/metrics')
def metrics():
    return generate_latest()
```

## Cleanup

```bash
helm uninstall prometheus -n monitoring
helm uninstall loki -n monitoring
kubectl delete namespace monitoring
```

---

**Next**: [Lab 11: Troubleshooting](11-troubleshooting.md)
