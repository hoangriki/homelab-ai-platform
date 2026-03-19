# Network Topology

## Overview

This document describes the **network architecture** used in the DevOps homelab platform. The goal of this design is to simulate a simplified version of a **modern enterprise network environment**, while maintaining a manageable structure for a home lab.

The network supports:

* Proxmox virtualization hosts
* Kubernetes cluster communication
* AI workload services
* monitoring infrastructure
* benchmarking traffic

The design follows common principles used in **cloud-native infrastructure networks**, including segmented workloads and internal service communication.

---

# Network Architecture Overview

The homelab network consists of three main layers:

```id="netarch"
Internet / ISP
      │
      ▼
Home Router / Firewall
      │
      ▼
Core Network Switch
      │
      ├── Proxmox Hosts
      │
      ├── Raspberry Pi Kubernetes Nodes
      │
      └── Management Workstation
```

All infrastructure nodes connect to a **single Layer 2 network**, while Kubernetes handles service-level networking internally.

---

# Physical Network Layout

Example physical connectivity.

```id="physnet"
Home Router
     │
     ▼
Managed Switch
     │
     ├── HP Z1 Mini #1 (Proxmox)
     ├── HP Z1 Mini #2 (Proxmox)
     │
     ├── Raspberry Pi 5 #1
     ├── Raspberry Pi 5 #2
     ├── Raspberry Pi 5 #3
     └── Raspberry Pi 5 #4
```

Each device is connected using **Gigabit Ethernet** where possible to reduce latency between cluster nodes.

---

# Network Addressing Plan

The homelab uses a static private network range.

| Component      | IP Address   | Description         |
| -------------- | ------------ | ------------------- |
| Router         | 192.168.1.1  | Default gateway     |
| Proxmox Host 1 | 192.168.1.10 | Virtualization node |
| Proxmox Host 2 | 192.168.1.11 | Virtualization node |
| Raspberry Pi 1 | 192.168.1.20 | Kubernetes worker   |
| Raspberry Pi 2 | 192.168.1.21 | Kubernetes worker   |
| Raspberry Pi 3 | 192.168.1.22 | Kubernetes worker   |
| Raspberry Pi 4 | 192.168.1.23 | Kubernetes worker   |

Subnet configuration:

```id="subnetcfg"
Subnet: 192.168.1.0/24
Gateway: 192.168.1.1
DNS: 1.1.1.1
```

Static addressing simplifies infrastructure automation and cluster configuration.

---

# Proxmox Network Configuration

Proxmox uses a Linux bridge to provide networking for virtual machines.

Example bridge configuration:

```id="vmbrlayout"
vmbr0
│
├── Proxmox Host Network
└── Virtual Machines
```

This allows VMs to behave as **full network devices on the LAN**.

Example configuration file:

```id="bridgeconfig"
/etc/network/interfaces
```

Example bridge definition:

```bash id="bridgeexample"
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge_ports eno1
    bridge_stp off
    bridge_fd 0
```

---

# Kubernetes Networking

Kubernetes provides **pod-to-pod networking across all cluster nodes**.

Cluster networking includes:

* Pod network
* Service network
* Node network

Example layout:

```id="k8snet"
Node Network
192.168.1.0/24

Pod Network
10.244.0.0/16

Service Network
10.96.0.0/12
```

This allows Kubernetes services to communicate internally regardless of which node the pods are running on.

---

# Service Communication Flow

Example request flow when interacting with an LLM service.

```id="svcflow"
User Request
      │
      ▼
Kubernetes Service
      │
      ▼
LLM Pod
      │
      ▼
Response Returned
```

The service acts as a **load-balanced entry point** for the LLM containers.

---

# Observability Traffic

Monitoring systems collect metrics from across the cluster.

Metrics flow example:

```id="metricsflow"
Cluster Nodes
      │
      ▼
Prometheus Scraping
      │
      ▼
Metrics Storage
      │
      ▼
Grafana Dashboards
```

Prometheus collects metrics from:

* Kubernetes nodes
* pods
* node exporters
* monitoring services

---

# Security Considerations

Even in a homelab environment, several best practices are applied:

* Static IP address allocation
* internal-only Kubernetes services
* firewall protections at the router
* restricted SSH access
* monitoring for abnormal resource usage

Future improvements may include:

* VLAN segmentation
* network policies in Kubernetes
* zero-trust service authentication

---

# Future Network Improvements

Potential enhancements for the network architecture include:

### VLAN Segmentation

Separating infrastructure into logical segments:

| VLAN       | Purpose               |
| ---------- | --------------------- |
| Management | Proxmox and SSH       |
| Kubernetes | cluster nodes         |
| Services   | application workloads |
| Monitoring | observability tools   |

---

### Software Defined Networking

Possible integrations:

* Cilium
* Calico
* Kubernetes Network Policies

These tools provide **fine-grained traffic control between services**.

---

# Summary

The homelab network provides the foundation required to support:

```id="netsummary"
Virtualized infrastructure
Kubernetes cluster communication
AI workload traffic
Monitoring systems
Benchmarking tools
```

The design prioritizes **simplicity, reliability, and extensibility**, making it ideal for experimentation and DevOps learning.

This topology reflects networking patterns commonly used in **cloud-native infrastructure platforms**.
