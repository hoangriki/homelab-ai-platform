# 01 – Proxmox Installation Guide (HP Z1 Mini)

## Overview

This guide walks through installing **Proxmox VE** on the two **HP Z1 Mini desktops** used in the homelab. Proxmox will act as the **virtualization layer** for the platform, hosting the Kubernetes control-plane VMs, AI benchmarking VM, and monitoring infrastructure.

At the end of this guide you will have:

* Two Proxmox hosts running on HP Z1 Minis
* Static IP configuration
* Web management access
* Base system updates applied
* SSH access enabled

This forms the **foundation of the entire homelab platform**.

---

## Hardware Used

| Device        | Role         |
| ------------- | ------------ |
| HP Z1 Mini #1 | Proxmox Host |
| HP Z1 Mini #2 | Proxmox Host |

Recommended minimum resources per host:

* CPU: 8 cores
* RAM: 16GB+
* Storage: 256GB SSD or larger

---

## Network Plan

Example network layout used in this project:

| Hostname | IP Address   | Role         |
| -------- | ------------ | ------------ |
| z1-1     | 192.168.1.10 | Proxmox Host |
| z1-2     | 192.168.1.11 | Proxmox Host |

Gateway:

```
192.168.1.1
```

Subnet:

```
255.255.255.0
```

DNS:

```
1.1.1.1
8.8.8.8
```

---

# Step 1 – Download Proxmox

Download the latest Proxmox VE ISO:

https://www.proxmox.com/en/downloads/category/iso-images-pve

File example:

```
proxmox-ve_8.x.iso
```

---

# Step 2 – Create Bootable USB

Use one of the following tools:

MacOS:

```
balenaEtcher
```

Windows:

```
Rufus
```

Linux:

```
dd
```

Example (Linux):

```bash
sudo dd if=proxmox-ve.iso of=/dev/sdX bs=4M status=progress
```

Replace `/dev/sdX` with your USB device.

---

# Step 3 – BIOS Configuration

Boot the HP Z1 Mini and enter BIOS.

Recommended settings:

Enable:

* Intel VT-x
* Intel VT-d (if available)
* UEFI Boot

Disable:

* Secure Boot (recommended)

Save changes and reboot.

---

# Step 4 – Install Proxmox

Insert the bootable USB and boot the system.

Select:

```
Install Proxmox VE
```

Follow the installer prompts.

### Disk Selection

Choose the main SSD for installation.

Default filesystem:

```
ext4
```

(ZFS is optional but not required for this lab.)

---

### Country / Timezone

Set appropriate region settings.

Example:

```
Region: United States
Timezone: America/Los_Angeles
Keyboard: US
```

---

### Administrator Account

Create the root account.

Example:

```
Username: root
Password: <strong password>
Email: your-email@example.com
```

---

### Network Configuration

Set static IP configuration.

Example for **Host 1**:

```
Hostname: z1-1
IP Address: 192.168.1.10
Gateway: 192.168.1.1
DNS: 1.1.1.1
```

Example for **Host 2**:

```
Hostname: z1-2
IP Address: 192.168.1.11
Gateway: 192.168.1.1
DNS: 1.1.1.1
```

Complete installation and reboot.

---

# Step 5 – Access Proxmox Web UI

After installation completes, open a browser and navigate to:

```
https://192.168.1.10:8006
```

and

```
https://192.168.1.11:8006
```

Login with:

```
Username: root
Realm: Linux PAM
Password: <your password>
```

You should now see the **Proxmox dashboard**.

---

# Step 6 – Update Proxmox

SSH into the host or use the web terminal.

Run:

```bash
apt update
apt full-upgrade -y
```

Reboot if required:

```bash
reboot
```

---

# Step 7 – Enable SSH Access

Confirm SSH service is active:

```bash
systemctl status ssh
```

If not active:

```bash
systemctl enable ssh
systemctl start ssh
```

Test from your workstation:

```bash
ssh root@192.168.1.10
```

---

# Step 8 – Configure Local Storage

Verify local storage pools in the web UI.

Navigate to:

```
Datacenter → Storage
```

Default storage:

```
local
local-lvm
```

These will store:

* VM disks
* ISO images
* Backups
* Containers

---

# Step 9 – Upload Ubuntu Server ISO

Navigate to:

```
Datacenter → z1-1 → local → ISO Images → Upload
```

Upload:

```
ubuntu-24.04-live-server-amd64.iso
```

This ISO will be used to create the Kubernetes VMs.

---

# Verification Checklist

Confirm the following:

* Proxmox web interface reachable
* SSH access working
* System updated
* Ubuntu ISO uploaded
* Both hosts visible in the datacenter view

---

# Next Step

Proceed to:

```
docs/setup/02-proxmox-vm-creation.md
```

In the next guide we will create the virtual machines used for:

* Kubernetes control plane
* AI benchmarking workloads
* Monitoring stack
