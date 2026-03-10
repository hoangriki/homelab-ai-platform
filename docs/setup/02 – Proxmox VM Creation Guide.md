# 02 – Proxmox VM Creation Guide

## Overview

This guide covers creating the **core virtual machines** used by the homelab platform.

These VMs will run:

* Kubernetes control plane
* AI benchmarking workloads
* Monitoring stack (Prometheus + Grafana)

All VMs will be hosted on the **Proxmox nodes running on the HP Z1 Mini desktops**.

The goal is to build a **small but production-style cluster architecture** that can support container orchestration, AI workloads, and infrastructure experimentation.

---

# Target Architecture

After completing this guide, the virtualization layout will look like this:

```
HP Z1 Mini (z1-1)
│
├── k8s-master-1
├── ai-benchmark
└── monitoring

HP Z1 Mini (z1-2)
│
└── k8s-master-2
```

These VMs will later integrate with the **Raspberry Pi 5 worker nodes** to form a mixed-architecture Kubernetes cluster.

---

# VM Specifications

| VM Name      | Host | CPU     | RAM  | Disk  | Purpose                   |
| ------------ | ---- | ------- | ---- | ----- | ------------------------- |
| k8s-master-1 | z1-1 | 4 cores | 8GB  | 40GB  | Kubernetes control plane  |
| k8s-master-2 | z1-2 | 4 cores | 8GB  | 40GB  | Kubernetes control plane  |
| ai-benchmark | z1-1 | 8 cores | 16GB | 100GB | LLM inference and testing |
| monitoring   | z1-1 | 2 cores | 4GB  | 30GB  | Prometheus + Grafana      |

---

# Step 1 – Open Proxmox Web Interface

Login to your Proxmox node:

```
https://192.168.1.10:8006
```

Navigate to:

```
Datacenter → z1-1
```

Click:

```
Create VM
```

---

# Step 2 – Configure General Settings

Example for the first VM:

```
VM ID: 100
Name: k8s-master-1
```

Node:

```
z1-1
```

Click **Next**.

---

# Step 3 – Select Installation Media

Choose the Ubuntu ISO uploaded earlier.

```
ISO Image: ubuntu-24.04-live-server-amd64.iso
```

Guest OS Type:

```
Linux
```

Version:

```
Ubuntu
```

Click **Next**.

---

# Step 4 – System Configuration

Recommended settings:

```
BIOS: OVMF (UEFI)
Machine: q35
SCSI Controller: VirtIO SCSI
```

Enable:

```
Qemu Agent
```

This improves VM communication with Proxmox.

Click **Next**.

---

# Step 5 – Disk Configuration

Recommended disk settings:

```
Bus/Device: SCSI
Storage: local-lvm
Disk Size: 40GB
Format: raw
```

For the **AI benchmarking VM**, increase disk size:

```
100GB
```

Click **Next**.

---

# Step 6 – CPU Configuration

Example configurations:

### Kubernetes Control Plane

```
Cores: 4
Type: host
```

### AI Benchmark VM

```
Cores: 8
Type: host
```

### Monitoring VM

```
Cores: 2
```

Click **Next**.

---

# Step 7 – Memory Allocation

Example configurations:

### Kubernetes Control Plane

```
Memory: 8192 MB
```

### AI Benchmark

```
Memory: 16384 MB
```

### Monitoring

```
Memory: 4096 MB
```

Ballooning can remain enabled.

Click **Next**.

---

# Step 8 – Network Configuration

Use the default bridge:

```
Bridge: vmbr0
Model: VirtIO
```

This connects the VM to the same network as the Proxmox host.

Click **Next**.

---

# Step 9 – Confirm VM Creation

Review the configuration and click:

```
Finish
```

The VM will appear in the left panel.

---

# Step 10 – Install Ubuntu Server

Select the VM.

Click:

```
Console → Start
```

Follow the Ubuntu Server installer.

Recommended configuration:

Hostname examples:

```
k8s-master-1
k8s-master-2
ai-benchmark
monitoring
```

Create a user account:

```
username: homelab
```

Enable OpenSSH during installation.

Partitioning:

```
Use entire disk
```

Complete installation and reboot the VM.

---

# Step 11 – Configure Static IPs

After installation, assign static IPs.

Example layout:

| VM           | IP            |
| ------------ | ------------- |
| k8s-master-1 | 192.168.1.100 |
| k8s-master-2 | 192.168.1.101 |
| ai-benchmark | 192.168.1.110 |
| monitoring   | 192.168.1.120 |

Example Netplan configuration:

```
sudo nano /etc/netplan/00-installer-config.yaml
```

Example configuration:

```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1,8.8.8.8]
```

Apply configuration:

```
sudo netplan apply
```

---

# Step 12 – Install Base Tools

Run the following on all VMs:

```
sudo apt update
sudo apt upgrade -y
```

Install useful utilities:

```
sudo apt install -y \
curl \
vim \
git \
htop \
net-tools
```

---

# Step 13 – Enable QEMU Guest Agent

Inside each VM:

```
sudo apt install -y qemu-guest-agent
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent
```

Then enable it in Proxmox:

```
VM → Options → QEMU Guest Agent → Enabled
```

This allows Proxmox to read VM IPs and state.

---

# Verification Checklist

Confirm the following:

* All VMs are running
* Static IPs are reachable
* SSH access works
* System packages updated
* QEMU guest agent active

Test SSH from your workstation:

```
ssh homelab@192.168.1.100
```

---

# Next Step

Proceed to the next setup guide:

```
docs/setup/03-raspberry-pi-setup.md
```

This will prepare the **Raspberry Pi 5 nodes** that will join the Kubernetes cluster as worker nodes.
