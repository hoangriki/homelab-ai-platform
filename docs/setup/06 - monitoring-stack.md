# 06 – Monitoring Stack (Prometheus + Grafana)

## Overview

This guide deploys the **observability stack** used to monitor the homelab Kubernetes cluster.

The monitoring stack provides visibility into:

* Node resource usage (CPU, memory)
* Kubernetes pod performance
* LLM container resource consumption
* Cluster health and scheduling behavior

We will deploy:

* **Metrics Server** – Kubernetes resource metrics
* **Prometheus** – metrics collection
* **Grafana** – visualization dashboards

These tools allow us to **benchmark AI workloads and analyze system performance** across the cluster.

---

# Monitoring Architecture

After completing this guide, the observability stack will look like this:

```id="monarch"
Kubernetes Cluster
│
├── Monitoring Namespace
│   ├── Prometheus
│   ├── Grafana
│   └── Metrics Server
│
├── AI Namespace
│   └── LLM Pods
│
└── Worker / Control Nodes
```

Prometheus collects metrics from nodes and pods, while Grafana visualizes them.

---

# Step 1 – Create Monitoring Namespace

Create a namespace for monitoring services.

```bash id="mkmonns"
kubectl create namespace monitoring
```

Verify:

```bash id="ckmonns"
kubectl get namespaces
```

You should see:

```id="monnsout"
monitoring
```

---

# Step 2 – Install Kubernetes Metrics Server

Metrics Server provides CPU and memory metrics for nodes and pods.

Install it with:

```bash id="metricsinstall"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Verify deployment:

```bash id="metricscheck"
kubectl get deployment metrics-server -n kube-system
```

Wait until status shows:

```id="metricsready"
AVAILABLE
```

Test node metrics:

```bash id="nodemetrics"
kubectl top nodes
```

Example output:

```id="nodemetricsout"
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
k8s-master-1   300m         7%     2100Mi          25%
pi5-1          120m         4%     800Mi           18%
```

---

# Step 3 – Install Helm (if not already installed)

Helm simplifies Kubernetes application deployment.

Install Helm:

```bash id="helminstall"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify installation:

```bash id="helmverify"
helm version
```

---

# Step 4 – Add Prometheus Helm Repository

Add the community Prometheus chart repository.

```bash id="addrepo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

---

# Step 5 – Install Prometheus

Deploy Prometheus into the monitoring namespace.

```bash id="installprom"
helm install prometheus prometheus-community/prometheus \
--namespace monitoring
```

Verify pods:

```bash id="checkprom"
kubectl get pods -n monitoring
```

Expected output:

```id="prompods"
prometheus-server-xxxxx     Running
prometheus-node-exporter    Running
```

Prometheus is now collecting metrics from cluster nodes.

---

# Step 6 – Install Grafana

Add the Grafana Helm repository.

```bash id="grafanarepo"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

Install Grafana:

```bash id="installgrafana"
helm install grafana grafana/grafana \
--namespace monitoring
```

Verify pods:

```bash id="checkgrafana"
kubectl get pods -n monitoring
```

Expected output:

```id="grafanapod"
grafana-xxxxx   Running
```

---

# Step 7 – Retrieve Grafana Admin Password

Get the Grafana admin password.

```bash id="grafpass"
kubectl get secret --namespace monitoring grafana \
-o jsonpath="{.data.admin-password}" | base64 --decode
```

Example output:

```id="grafpassout"
adminpassword123
```

---

# Step 8 – Access Grafana Dashboard

Forward the Grafana service locally.

```bash id="grafport"
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Open a browser:

```id="grafurl"
http://localhost:3000
```

Login credentials:

```id="graflogin"
Username: admin
Password: <retrieved password>
```

---

# Step 9 – Add Prometheus as Data Source

Inside the Grafana UI:

1. Navigate to **Settings → Data Sources**
2. Click **Add Data Source**
3. Select **Prometheus**

Prometheus URL:

```id="promurl"
http://prometheus-server.monitoring.svc.cluster.local
```

Save and test the data source.

---

# Step 10 – Import Kubernetes Dashboards

Recommended dashboards:

* **Kubernetes Cluster Monitoring**
* **Node Exporter Full**
* **Kubernetes Pod Metrics**

Import dashboards via:

```id="grafdash"
Dashboards → Import
```

Example dashboard IDs:

| Dashboard                     | ID   |
| ----------------------------- | ---- |
| Node Exporter Full            | 1860 |
| Kubernetes Cluster Monitoring | 315  |
| Kubernetes Pod Metrics        | 6417 |

---

# Step 11 – Monitor LLM Workloads

Once dashboards are active, you can observe:

* CPU usage for LLM containers
* Memory usage of inference pods
* Node resource saturation
* Scheduling across ARM vs x86 nodes

Example commands:

```bash id="podmetrics"
kubectl top pods -n ai
```

Example output:

```id="podmetricsout"
llama3-xxxxx   2500m CPU   7Gi RAM
```

This is useful for **benchmarking and scaling experiments**.

---

# Verification Checklist

Confirm the following:

* Monitoring namespace created
* Metrics Server installed
* Prometheus running
* Grafana accessible
* Prometheus connected as data source
* Dashboards displaying cluster metrics

---

# Result

Your homelab now includes a full **observability stack**.

```id="monstack"
Prometheus – metrics collection
Grafana – visualization dashboards
Metrics Server – Kubernetes resource metrics
```

This enables **performance analysis of AI workloads and cluster health monitoring**.

---

# Next Step

Proceed to:

```id="nextbench"
docs/setup/07-ai-benchmarking.md
```

The next guide will demonstrate how to:

* run **load tests against LLM endpoints**
* measure **tokens/sec and latency**
* analyze performance using **Grafana dashboards**
* compare **ARM vs x86 compute behavior**.
