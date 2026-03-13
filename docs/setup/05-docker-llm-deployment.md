# 05 – Docker LLM Deployment

## Overview

This guide deploys **local Large Language Model (LLM) inference services** inside the Kubernetes cluster.

The goal is to:

* Run LLM inference locally in the homelab
* Deploy containers using Kubernetes
* Test scheduling across x86 and ARM nodes
* Benchmark AI model performance
* Prepare the cluster for scaling experiments

The deployment will use **Ollama**, a lightweight LLM runtime that simplifies running open-source models locally.

---

# Target Deployment Architecture

After completing this guide, the cluster will run:

```
Kubernetes Cluster
│
├── LLM Services
│   ├── llama3 inference pod
│   └── mistral inference pod
│
├── Control Plane
│   ├── k8s-master-1
│   └── k8s-master-2
│
└── Worker Nodes
    ├── pi5-1
    ├── pi5-2
    ├── pi5-3
    └── pi5-4
```

The **LLM pods will run on the x86 nodes** because the Raspberry Pi devices do not have enough memory for most LLM workloads.

---

# Step 1 – Create Namespace for AI Workloads

Namespaces help isolate workloads.

Create an AI namespace:

```bash
kubectl create namespace ai
```

Verify:

```bash
kubectl get namespaces
```

Expected output includes:

```
ai
default
kube-system
```

---

# Step 2 – Create LLM Deployment File

Create the directory in your repository:

```
kubernetes/llms/llama3/
```

Create the deployment file:

```
deployment.yaml
```

Example deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llama3
  namespace: ai
spec:
  replicas: 1
  selector:
    matchLabels:
      app: llama3
  template:
    metadata:
      labels:
        app: llama3
    spec:
      nodeSelector:
        arch: amd64
      containers:
      - name: llama3
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        resources:
          limits:
            cpu: "4"
            memory: "8Gi"
```

This ensures the container runs only on **x86 nodes**.

---

# Step 3 – Create Service for the LLM

Create:

```
service.yaml
```

Example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: llama3
  namespace: ai
spec:
  selector:
    app: llama3
  ports:
  - protocol: TCP
    port: 11434
    targetPort: 11434
  type: ClusterIP
```

This exposes the LLM internally inside the cluster.

---

# Step 4 – Deploy the LLM

Apply the deployment.

```bash
kubectl apply -f kubernetes/llms/llama3/deployment.yaml
kubectl apply -f kubernetes/llms/llama3/service.yaml
```

Verify pods:

```bash
kubectl get pods -n ai
```

Expected output:

```
llama3-xxxxx   Running
```

Check where it is scheduled:

```bash
kubectl get pods -n ai -o wide
```

The pod should run on:

```
k8s-master-1 or k8s-master-2
```

---

# Step 5 – Pull the LLM Model

Connect to the pod:

```bash
kubectl exec -it deployment/llama3 -n ai -- bash
```

Pull the model:

```bash
ollama pull llama3
```

Exit the container.

---

# Step 6 – Test the LLM API

Forward the service locally:

```bash
kubectl port-forward svc/llama3 11434:11434 -n ai
```

Test using curl:

```bash
curl http://localhost:11434/api/generate \
-d '{
  "model": "llama3",
  "prompt": "Explain Kubernetes in one paragraph"
}'
```

You should receive a generated response.

---

# Step 7 – Deploy Additional Model (Optional)

Create another directory:

```
kubernetes/llms/mistral/
```

Repeat the deployment process for:

```
mistral
```

This allows comparison between models.

---

# Step 8 – Scale the LLM Deployment

Increase the number of replicas.

Example:

```bash
kubectl scale deployment llama3 --replicas=2 -n ai
```

Check pods:

```bash
kubectl get pods -n ai
```

You should see multiple LLM instances running.

---

# Step 9 – Observe Resource Usage

Monitor node resources.

```bash
kubectl top nodes
```

Monitor pods:

```bash
kubectl top pods -n ai
```

This provides insights into:

* CPU usage
* Memory usage
* Resource limits

---

# Step 10 – Clean Up (Optional)

Delete the deployment if needed.

```bash
kubectl delete deployment llama3 -n ai
kubectl delete service llama3 -n ai
```

---

# Verification Checklist

Confirm the following:

* AI namespace created
* LLM pod running
* Model downloaded successfully
* API responding to prompts
* Pod scheduled on x86 nodes

---

# Result

Your homelab now supports:

```
Local LLM inference
Containerized AI workloads
Kubernetes scheduling
Multi-node cluster execution
```

This environment can now be used for **AI benchmarking and scaling experiments**.

---

# Next Step

Proceed to:

```
docs/setup/06-monitoring-stack.md
```

In the next guide we will deploy:

* Prometheus
* Grafana
* Kubernetes metrics server

This will allow **performance monitoring and benchmarking of LLM workloads** across the cluster.
