# 03 – Raspberry Pi 5 Setup Guide

## Overview

This guide prepares the **Raspberry Pi 5 nodes** that will act as **Kubernetes worker nodes** in the homelab cluster.

These nodes provide:

* Lightweight compute capacity
* ARM-based workloads
* Edge AI capabilities
* Distributed Kubernetes scheduling

The Raspberry Pi nodes will eventually join the Kubernetes cluster managed by the **control-plane VMs running on Proxmox**.

---

# Hardware Used

| Device            | Role                             |
| ----------------- | -------------------------------- |
| Raspberry Pi 5 #1 | Kubernetes Worker Node           |
| Raspberry Pi 5 #2 | Kubernetes Worker Node           |
| Raspberry Pi 5 #3 | Kubernetes Worker Node           |
| Raspberry Pi 5 #4 | Edge AI Worker (optional AI HAT) |

Recommended configuration:

* Raspberry Pi 5 (8GB RAM preferred)
* 32GB+ microSD card or NVMe HAT storage
* Ethernet connection (recommended for cluster stability)

---

# Network Plan

Example network layout used in this project:

| Hostname | IP Address   | Role              |
| -------- | ------------ | ----------------- |
| pi5-1    | 192.168.1.20 | Kubernetes worker |
| pi5-2    | 192.168.1.21 | Kubernetes worker |
| pi5-3    | 192.168.1.22 | Kubernetes worker |
| pi5-4    | 192.168.1.23 | Edge AI node      |

Gateway:

```id="gwpi"
192.168.1.1
```

DNS:

```id="dnspi"
1.1.1.1
8.8.8.8
```

---

# Step 1 – Flash Ubuntu Server

Download **Ubuntu Server for Raspberry Pi (64-bit)**:

https://ubuntu.com/download/raspberry-pi

Recommended version:

```id="ubuversion"
Ubuntu Server 24.04 LTS (ARM64)
```

Flash the image using **Raspberry Pi Imager** or **balenaEtcher**.

Recommended options:

* Enable SSH
* Set hostname
* Configure Wi-Fi (optional, Ethernet preferred)
* Set username and password

Example hostname during flash:

```id="hostnames"
pi5-1
pi5-2
pi5-3
pi5-4
```

Insert the SD card and boot the Raspberry Pi.

---

# Step 2 – Initial Login

Connect via SSH from your workstation.

Example:

```bash id="sshlogin"
ssh ubuntu@192.168.1.20
```

Default username (if using Ubuntu image):

```id="defaultuser"
ubuntu
```

Update the system:

```bash id="updatepi"
sudo apt update
sudo apt upgrade -y
```

---

# Step 3 – Set Static IP Address

Edit the Netplan configuration:

```bash id="editnetplan"
sudo nano /etc/netplan/50-cloud-init.yaml
```

Example configuration for **pi5-1**:

```yaml id="netplanexample"
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.20/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1,8.8.8.8]
```

Apply configuration:

```bash id="applynetplan"
sudo netplan apply
```

Repeat for each node using its assigned IP.

---

# Step 4 – Configure Hostnames

Set the hostname to match the node role.

Example:

```bash id="sethostname"
sudo hostnamectl set-hostname pi5-1
```

Update `/etc/hosts`:

```bash id="edithosts"
sudo nano /etc/hosts
```

Add entries for all nodes:

```id="hoststable"
192.168.1.20 pi5-1
192.168.1.21 pi5-2
192.168.1.22 pi5-3
192.168.1.23 pi5-4
```

---

# Step 5 – Install Required Base Packages

Install basic utilities used throughout the lab.

```bash id="installbase"
sudo apt install -y \
curl \
git \
vim \
htop \
net-tools \
build-essential
```

---

# Step 6 – Install Docker

Docker will be used to run containers locally and by Kubernetes.

Install Docker:

```bash id="installdocker"
sudo apt install -y docker.io
```

Enable the Docker service:

```bash id="dockerenable"
sudo systemctl enable docker
sudo systemctl start docker
```

Add your user to the Docker group:

```bash id="dockergroup"
sudo usermod -aG docker $USER
```

Log out and back in to apply group changes.

Verify Docker installation:

```bash id="dockertest"
docker run hello-world
```

---

# Step 7 – Enable cgroup Support (Required for Kubernetes)

Edit the boot configuration:

```bash id="editcmdline"
sudo nano /boot/firmware/cmdline.txt
```

Add the following parameters to the end of the line:

```id="cgroups"
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

Reboot the system:

```bash id="rebootpi"
sudo reboot
```

---

# Step 8 – Verify System Resources

Check CPU and memory availability.

```bash id="checkcpu"
lscpu
```

Check memory:

```bash id="checkram"
free -h
```

Check disk:

```bash id="checkdisk"
df -h
```

---

# Step 9 – Optional: Prepare Edge AI Node

If one Raspberry Pi will use an **AI HAT accelerator**, designate it as the edge node.

Example:

```id="edgenode"
pi5-4
```

This node can later run:

* Object detection
* Camera inference workloads
* Edge AI pipelines

It can also be labeled in Kubernetes for hardware-aware scheduling.

---

# Verification Checklist

Confirm the following on each Raspberry Pi:

* Static IP configured
* SSH access working
* Docker installed and running
* System updated
* Hostname set correctly

Test connectivity from your workstation:

```bash id="pingtest"
ping 192.168.1.20
```

---

# Resulting Worker Nodes

After completing this guide you should have:

```
pi5-1   → Kubernetes worker
pi5-2   → Kubernetes worker
pi5-3   → Kubernetes worker
pi5-4   → Edge AI worker
```

These nodes will be connected to the Kubernetes control-plane running on the Proxmox VMs.

---

# Next Step

Proceed to:

```id="nextstepk3s"
docs/setup/04-kubernetes-cluster.md
```

The next guide will install **k3s Kubernetes** and connect:

* Proxmox VM control-plane nodes
* Raspberry Pi worker nodes

to form the full cluster.
