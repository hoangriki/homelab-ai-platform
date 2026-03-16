# 07 – AI Benchmarking and Load Testing

## Overview

This guide explains how to **benchmark Large Language Model (LLM) inference performance** running in the Kubernetes cluster.

Benchmarking helps evaluate:

* LLM response latency
* Throughput under concurrent load
* CPU and memory utilization
* Node-level performance differences
* Scaling behavior of Kubernetes deployments

These tests will generate measurable data that can be visualized in **Grafana dashboards** deployed earlier.

---

# Benchmarking Goals

The benchmarking process focuses on answering the following questions:

* How many requests per second can the cluster handle?
* How much CPU and memory does an LLM pod consume?
* How does performance change when scaling replicas?
* Do x86 nodes outperform ARM nodes for AI workloads?
* What happens when cluster load increases?

---

# Benchmarking Architecture

The testing setup looks like this:

```id="bencharch"
Load Generator (k6)
        │
        │ HTTP Requests
        ▼
Kubernetes Service (LLM API)
        │
        ▼
LLM Pods (Ollama)
        │
        ▼
Cluster Nodes (x86 / ARM)
        │
        ▼
Prometheus Metrics
        │
        ▼
Grafana Dashboards
```

---

# Step 1 – Create Benchmarking Directory

Inside the repository:

```id="benchdir"
benchmarking/load-tests/
```

Create a test script:

```id="benchfile"
k6-llm-test.js
```

---

# Step 2 – Install k6 Load Testing Tool

Install k6 on your workstation or control-plane VM.

Ubuntu installation:

```bash id="installk6"
sudo apt install -y gnupg software-properties-common
curl -fsSL https://dl.k6.io/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/k6.gpg
echo "deb [signed-by=/usr/share/keyrings/k6.gpg] https://dl.k6.io/deb stable main" | \
sudo tee /etc/apt/sources.list.d/k6.list
sudo apt update
sudo apt install k6
```

Verify installation:

```bash id="checkk6"
k6 version
```

---

# Step 3 – Create Load Testing Script

Example **k6 test script**.

```javascript id="k6script"
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 5,
  duration: '60s',
};

export default function () {
  const url = 'http://localhost:11434/api/generate';

  const payload = JSON.stringify({
    model: "llama3",
    prompt: "Explain Kubernetes in simple terms"
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  let res = http.post(url, payload, params);

  check(res, {
    'status was 200': (r) => r.status === 200,
  });

  sleep(1);
}
```

This script will simulate **multiple users sending prompts to the LLM API**.

---

# Step 4 – Forward the LLM Service

Expose the LLM service locally.

```bash id="portforwardllm"
kubectl port-forward svc/llama3 11434:11434 -n ai
```

Verify the endpoint:

```bash id="curltest"
curl http://localhost:11434/api/tags
```

You should see available models.

---

# Step 5 – Run Benchmark Test

Execute the load test.

```bash id="runbench"
k6 run benchmarking/load-tests/k6-llm-test.js
```

Example output:

```id="k6output"
running (1m00s), 5/5 VUs

http_req_duration: avg=950ms
http_reqs: 300
checks: 100% passed
```

This indicates how long the LLM took to respond under load.

---

# Step 6 – Monitor Kubernetes Metrics

While the benchmark runs, observe cluster metrics.

Check pod resource usage:

```bash id="benchpods"
kubectl top pods -n ai
```

Example output:

```id="benchpodsout"
llama3-xxxx   2800m CPU   7.5Gi RAM
```

Check node metrics:

```bash id="benchnodes"
kubectl top nodes
```

This shows which nodes are under heavy load.

---

# Step 7 – Observe Grafana Dashboards

Open the Grafana dashboard deployed earlier:

```id="grafanabench"
http://localhost:3000
```

Key metrics to observe:

* CPU utilization per node
* Memory usage per pod
* Network traffic
* Pod restart events
* Request latency

These dashboards provide **real-time visibility into AI workloads**.

---

# Step 8 – Scale the LLM Deployment

Increase the number of inference pods.

```bash id="scalellm"
kubectl scale deployment llama3 --replicas=2 -n ai
```

Verify scaling:

```bash id="checkscale"
kubectl get pods -n ai
```

Example output:

```id="scaleout"
llama3-abcde
llama3-fghij
```

Run the benchmark again and compare results.

---

# Step 9 – Record Benchmark Results

Store benchmarking observations in:

```id="resultsdir"
benchmarking/results/
```

Example file:

```id="resultfile"
llm-performance.md
```

Document metrics such as:

| Test Scenario | Avg Latency | Requests/sec | CPU Usage |
| ------------- | ----------- | ------------ | --------- |
| 1 Pod         | 950 ms      | 5 rps        | 80%       |
| 2 Pods        | 600 ms      | 10 rps       | 70%       |

This data helps evaluate **cluster scaling efficiency**.

---

# Step 10 – Optional Advanced Tests

Additional experiments can include:

### High Concurrency

```id="highvu"
vus: 20
```

### Long Duration Testing

```id="longtest"
duration: '10m'
```

### Model Comparisons

Deploy additional models such as:

```id="modelcompare"
mistral
phi
codellama
```

Benchmark each model independently.

---

# Verification Checklist

Confirm the following:

* k6 load test successfully executed
* LLM API responded to requests
* Kubernetes metrics recorded
* Grafana dashboards updated
* Benchmark results documented

---

# Result

Your homelab now supports **AI workload benchmarking**.

```id="benchresult"
LLM inference testing
Load testing with k6
Cluster performance monitoring
Scaling experiments
```

This environment now closely mirrors **real-world AI infrastructure testing environments**.

---

# Next Step

Proceed to:

```id="nextinfra"
docs/setup/08-terraform-infrastructure.md
```

In the next guide we will automate the homelab infrastructure using **Terraform**, enabling reproducible deployments of:

* Proxmox virtual machines
* Docker containers
* Kubernetes resources
* AI workloads.
