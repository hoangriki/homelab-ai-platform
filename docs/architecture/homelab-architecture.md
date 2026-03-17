# Homelab Architecture

## Overview

This document describes the **full architecture of the DevOps / SRE homelab platform**. The environment simulates a modern infrastructure stack used in real-world production environments, combining virtualization, container orchestration, AI workloads, observability, and infrastructure automation.

The homelab was designed to demonstrate practical experience with:

* Infrastructure as Code
* Kubernetes cluster operations
* containerized workloads
* AI model deployment
* monitoring and observability
* load testing and benchmarking

This architecture mirrors patterns used in **cloud-native platforms and DevOps production environments**.

---

# High-Level Architecture

The platform consists of four main infrastructure layers.

```id="highlevel"
Infrastructure Layer
│
├── Virtualization (Proxmox)
│
├── Container Platform (Kubernetes)
│
├── Workloads
│   ├── AI Models
│   └── Benchmarking Tools
│
└── Observability
    ├── Prometheus
    └── Grafana
```

Each layer provides functionality required to operate modern distributed systems.

---

# Physical Infrastructure

The homelab runs on a hybrid ARM and x86 environment.

| Device            | Role              | Architecture |
| ----------------- | ----------------- | ------------ |
| HP Z1 Mini #1     | Proxmox Host      | x86          |
| HP Z1 Mini #2     | Proxmox Host      | x86          |
| Raspberry Pi 5 #1 | Kubernetes Worker | ARM          |
| Raspberry Pi 5 #2 | Kubernetes Worker | ARM          |
| Raspberry Pi 5 #3 | Kubernetes Worker | ARM          |
| Raspberry Pi 5 #4 | Kubernetes Worker | ARM          |

This mixed architecture enables testing workloads across **heterogeneous compute environments**.

---

# Virtualization Layer

The virtualization platform is powered by **Proxmox VE**.

Responsibilities:

* Virtual machine orchestration
* network bridging
* storage allocation
* cluster management

Example virtualization layout:

```id="proxmoxlayout"
Proxmox Cluster
│
├── z1-1
│   ├── k8s-master-1
│   ├── monitoring-vm
│   └── benchmarking-vm
│
└── z1-2
    ├── k8s-master-2
    └── worker-vm
```

Virtualization allows the environment to simulate **multi-node distributed systems**.

---

# Kubernetes Cluster

Kubernetes acts as the **container orchestration platform** for the homelab.

Cluster topology:

```id="k8scluster"
Kubernetes Cluster
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

Responsibilities:

* container scheduling
* workload orchestration
* resource allocation
* service networking
* cluster scaling

The cluster supports **multi-architecture container workloads**.

---

# AI Workload Layer

The platform runs **local large language models (LLMs)** for experimentation and benchmarking.

AI inference is powered by **Ollama containers**.

Example deployment:

```id="aideploy"
AI Namespace
│
├── llama3 deployment
│
├── mistral deployment
│
└── internal API service
```

The AI workloads provide a realistic environment for testing:

* CPU intensive inference workloads
* Kubernetes scaling behavior
* distributed resource utilization

Most LLM workloads are scheduled on **x86 nodes** due to higher available memory.

---

# Benchmarking and Load Testing

Benchmarking tools simulate real-world API traffic against the LLM services.

The platform uses **k6** to generate load against the LLM endpoints.

Testing workflow:

```id="benchflow"
k6 Load Generator
      │
      ▼
LLM API Endpoint
      │
      ▼
Kubernetes Pods
      │
      ▼
Cluster Nodes
```

Benchmarking helps measure:

* inference latency
* request throughput
* node resource consumption
* scaling efficiency

---

# Observability Stack

Monitoring is implemented using a **Prometheus + Grafana stack**.

Responsibilities:

| Tool           | Purpose                     |
| -------------- | --------------------------- |
| Prometheus     | metrics collection          |
| Grafana        | visualization dashboards    |
| Metrics Server | Kubernetes resource metrics |

Observability architecture:

```id="observability"
Cluster Metrics
     │
     ▼
Prometheus
     │
     ▼
Grafana Dashboards
```

This enables real-time monitoring of:

* node resource utilization
* pod performance
* cluster health
* AI workload metrics

---

# Infrastructure Automation

Infrastructure provisioning and management is handled using **Terraform**.

Terraform manages:

* Proxmox virtual machines
* Kubernetes namespaces
* application deployments
* infrastructure configuration

Automation workflow:

```id="tfworkflow"
Terraform
   │
   ├── Proxmox Provider
   │
   └── Kubernetes Provider
           │
           ▼
      Cluster Resources
```

Using Infrastructure as Code ensures:

* reproducible environments
* version-controlled infrastructure
* automated provisioning

---

# Repository Structure

The GitHub repository is organized to reflect the different layers of the platform.

```id="repostruct"
homelab-devops-platform/
│
├── docs/
│   ├── setup/
│   └── architecture/
│
├── kubernetes/
│   └── llms/
│
├── terraform/
│   ├── proxmox/
│   └── kubernetes/
│
├── benchmarking/
│   ├── load-tests/
│   └── results/
│
└── README.md
```

This structure follows patterns used in **production DevOps repositories**.

---

# Key Skills Demonstrated

This homelab demonstrates practical experience with:

* Kubernetes cluster operations
* containerized AI workloads
* infrastructure automation
* observability and monitoring
* performance benchmarking
* multi-node distributed systems

These skills directly map to **DevOps, SRE, and Cloud Engineering roles**.

---

# Future Improvements

Potential expansions for the homelab include:

* CI/CD pipelines for automated deployments
* GitOps workflows using ArgoCD
* GPU acceleration for AI workloads
* distributed storage using Ceph
* service mesh with Istio

These additions would further simulate **enterprise cloud-native platforms**.

---

# Summary

The homelab provides a **fully functional DevOps platform** capable of running distributed workloads, monitoring system health, and benchmarking AI inference performance.

The environment combines:

```id="summaryarch"
Proxmox virtualization
Kubernetes orchestration
Docker containers
Local LLM inference
Prometheus monitoring
Grafana dashboards
Terraform automation
```

This architecture demonstrates how modern infrastructure systems are **designed, deployed, and operated at scale**.
