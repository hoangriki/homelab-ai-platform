```bash
#!/bin/bash

# --------------------------------------------------
# Kubernetes Homelab Cluster Bootstrap Script
# --------------------------------------------------
# This script prepares Ubuntu nodes for Kubernetes
# by installing required dependencies and configuring
# the container runtime.
#
# Supported nodes:
# - Proxmox VM Kubernetes masters
# - Raspberry Pi worker nodes
# --------------------------------------------------

set -e

echo "Starting Kubernetes node bootstrap..."

# --------------------------------------------------
# Update System
# --------------------------------------------------

echo "Updating system packages..."

sudo apt update
sudo apt upgrade -y

# --------------------------------------------------
# Install Required Dependencies
# --------------------------------------------------

echo "Installing dependencies..."

sudo apt install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg \
lsb-release

# --------------------------------------------------
# Disable Swap (Required by Kubernetes)
# --------------------------------------------------

echo "Disabling swap..."

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# --------------------------------------------------
# Install Container Runtime (containerd)
# --------------------------------------------------

echo "Installing containerd..."

sudo apt install -y containerd

sudo mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# --------------------------------------------------
# Configure Kernel Modules
# --------------------------------------------------

echo "Configuring kernel modules..."

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# --------------------------------------------------
# Configure Sysctl for Kubernetes Networking
# --------------------------------------------------

echo "Configuring sysctl parameters..."

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# --------------------------------------------------
# Install Kubernetes Components
# --------------------------------------------------

echo "Installing Kubernetes components..."

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
| sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo 'deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' \
| sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt install -y \
kubelet \
kubeadm \
kubectl

sudo apt-mark hold kubelet kubeadm kubectl

# --------------------------------------------------
# Enable kubelet
# --------------------------------------------------

sudo systemctl enable kubelet

echo "--------------------------------------"
echo "Kubernetes prerequisites installed"
echo "--------------------------------------"
echo ""
echo "Next steps:"
echo ""
echo "On the control plane node run:"
echo "kubeadm init"
echo ""
echo "On worker nodes run the join command"
echo "provided by kubeadm."
echo ""
echo "--------------------------------------"
```
