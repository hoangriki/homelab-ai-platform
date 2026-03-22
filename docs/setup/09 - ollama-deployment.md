# 09 - Ollama Deployment

## Overview

This guide explains how to deploy **Ollama** in the homelab Kubernetes cluster to run **local LLM inference services**.  

It covers:

- Installing Ollama on x86 nodes
- Pulling and testing LLM models
- Exposing Ollama in Kubernetes
- Connecting benchmarking tools
- Testing from Kubernetes
- Benchmarking with k6

---

## 1. Install Ollama on x86 Node

SSH into your Proxmox VM or x86 Kubernetes node and run:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Verify installation:

ollama --version

Enable and start Ollama services:
sudo systemctl enable ollama
sudo systemctl start ollama
sudo systemctl status ollama

2. Pull a Model

Download an LLM for local inference:

ollama pull llama3

For smaller models (useful if RAM is limited):

ollama pull mistral
ollama pull phi

Example prompt:

Explain Kubernetes like I'm a DevOps engineer.

3. Expose the Ollama API

By default, Ollama runs an HTTP API on:

http://localhost:11434

Test the API:

curl http://localhost:11434/api/tags

```
{
  "models": [
    "llama3"
  ]
}
```
4. Optional: Run Ollama in Docker

For a containerized deployment:

```
docker run -d \
  --name ollama \
  -p 11434:11434 \
  -v ollama:/root/.ollama \
  ollama/ollama

```
5. Deploy Ollama to Kubernetes
Create Namespace
```
kubectl create namespace ai
```

Deployment Manifest (kubernetes/ai/ollama/deployment.yaml)
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: ai
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      nodeSelector:
        arch: amd64
      containers:
      - name: ollama
        image: ollama/ollama
        ports:
        - containerPort: 11434
        volumeMounts:
        - mountPath: /root/.ollama
          name: ollama-data
      volumes:
      - name: ollama-data
        emptyDir: {}

```

Apply the deployment:

```
kubectl apply -f kubernetes/ai/ollama/deployment.yaml

```

Service Manifest (kubernetes/ai/ollama/service.yaml)
```
apiVersion: v1
kind: Service
metadata:
  name: ollama
  namespace: ai
spec:
  selector:
    app: ollama
  ports:
    - port: 11434
      targetPort: 11434
  type: ClusterIP
```

Apply the service:

kubectl apply -f kubernetes/ai/ollama/service.yaml

Access Ollama inside the cluster:

http://ollama.ai.svc.cluster.local:11434
6. Test Ollama from Kubernetes

Run a test pod:

kubectl run curlpod --image=curlimages/curl -it --rm -- sh

Inside the pod, test API connectivity:

curl http://ollama.ai.svc.cluster.local:11434/api/tags

Expected output:

{
  "models": ["llama3"]
}
7. Connect Benchmarking

Your k6 load tests can now target Ollama:

http://ollama.ai.svc.cluster.local:11434/api/generate

Monitor:

Latency
Throughput
CPU / memory usage
Scaling behavior

Metrics can be visualized with Prometheus + Grafana.

8. Summary

By following this guide, your homelab now has a containerized local LLM inference platform fully integrated with:

Kubernetes cluster orchestration
Prometheus monitoring
k6 benchmarking
Next Steps
Add autoscaling for Ollama pods
Experiment with multiple LLMs across nodes
Monitor resource usage and latency for optimization
Optionally add a GPU/accelerator node for faster LLM inference

