# Homelab Architecture Diagram

## Overview

This document provides a **visual architecture diagram** of the DevOps homelab platform. The goal is to illustrate how the infrastructure components interact across the different layers of the environment.

The architecture includes:

* physical infrastructure
* virtualization
* container orchestration
* AI workloads
* monitoring systems
* infrastructure automation

This layered design reflects patterns commonly used in **cloud-native and DevOps platforms**.

---

# High-Level Architecture

```id="highleveldiagram"
+--------------------------------------------------+
|                    Internet                      |
+--------------------------------------------------+
                        |
                        v
+--------------------------------------------------+
|               Home Router / Firewall             |
+--------------------------------------------------+
                        |
                        v
+--------------------------------------------------+
|                Managed Network Switch            |
+--------------------------------------------------+
          |                         |
          v                         v

+------------------------+     +------------------------+
|      HP Z1 Mini #1     |     |      HP Z1 Mini #2     |
|       (Proxmox)        |     |       (Proxmox)        |
+------------------------+     +------------------------+
| - k8s-master-1         |     | - k8s-master-2         |
| - monitoring VM        |     | - benchmarking VM      |
+------------------------+     +------------------------+

          |                         |
          +-----------+-------------+
                      |
                      v

+--------------------------------------------------+
|                Kubernetes Cluster                 |
+--------------------------------------------------+

   Control Plane Nodes
   -------------------
   k8s-master-1
   k8s-master-2

   Worker Nodes
   -------------------
   Raspberry Pi 5 #1
   Raspberry Pi 5 #2
   Raspberry Pi 5 #3
   Raspberry Pi 5 #4

                      |
                      v

+--------------------------------------------------+
|               Containerized Workloads             |
+--------------------------------------------------+

   AI Workloads
   -------------------
   - llama3
   - mistral
   - codellama

   Observability Stack
   -------------------
   - Prometheus
   - Grafana
   - Metrics Server

   Benchmarking
   -------------------
   - k6 Load Testing

```

---

# Logical Infrastructure Layers

The architecture can also be represented as layered infrastructure.

```id="layereddiagram"
Layer 5 – Observability
----------------------------------
Grafana Dashboards
Prometheus Metrics

Layer 4 – Application Workloads
----------------------------------
LLM Inference Containers
Benchmarking Services

Layer 3 – Container Platform
----------------------------------
Kubernetes Cluster
Container Scheduling
Service Networking

Layer 2 – Virtualization
----------------------------------
Proxmox VE
Virtual Machines

Layer 1 – Physical Hardware
----------------------------------
HP Z1 Mini Nodes
Raspberry Pi 5 Nodes
```

This layered approach is commonly used when designing **cloud-native platforms**.

---

# AI Workload Data Flow

The following diagram shows how requests flow through the platform when interacting with an LLM service.

```id="aiflow"
User Request
     |
     v
Kubernetes Service
     |
     v
LLM Pod (Ollama Container)
     |
     v
LLM Model (llama3 / mistral)
     |
     v
Response Generated
     |
     v
Response Returned to User
```

---

# Monitoring Data Flow

Observability components collect metrics from the cluster.

```id="monitorflow"
Cluster Nodes
      |
      v
Node Exporters
      |
      v
Prometheus Scraping
      |
      v
Metrics Database
      |
      v
Grafana Dashboards
```

This allows monitoring of:

* cluster health
* resource utilization
* container performance
* AI workload metrics

---

# Infrastructure Automation Flow

Terraform automates infrastructure provisioning and deployment.

```id="terraformflow"
Terraform Configuration
        |
        v
Terraform Providers
        |
        +------------------------+
        |                        |
        v                        v
Proxmox API               Kubernetes API
        |                        |
        v                        v
Virtual Machines         Kubernetes Resources
```

Infrastructure changes are applied through **version-controlled Terraform code**.

---

# Future Architecture Enhancements

The homelab architecture can be extended to simulate additional enterprise capabilities.

Examples include:

### GitOps Platform

```
Git Repository
      |
      v
ArgoCD
      |
      v
Kubernetes Deployments
```

### Service Mesh

```
Istio
  |
  v
Service-to-Service Encryption
Traffic Routing
Observability
```

### GPU AI Acceleration

```
GPU Node
   |
   v
High-performance AI inference
```

---

# Summary

This architecture demonstrates a **full-stack DevOps infrastructure environment** capable of running distributed workloads and supporting modern cloud-native tooling.

Key technologies used in this platform include:

```
Proxmox virtualization
Kubernetes orchestration
Docker containers
Local AI model inference
Prometheus monitoring
Grafana visualization
Terraform automation
```

The homelab is designed to simulate the **core infrastructure patterns used by modern DevOps and SRE teams**.
