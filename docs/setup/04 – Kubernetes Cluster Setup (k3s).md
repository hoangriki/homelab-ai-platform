# 04 – Kubernetes Cluster Setup (k3s)

## Overview

This guide installs **Kubernetes using k3s** and connects all nodes in the homelab to form a **mixed-architecture cluster**.

The cluster will consist of:

* **Control Plane Nodes (x86)** – running on Proxmox VMs
* **Worker Nodes (ARM)** – running on Raspberry Pi 5 devices

This setup mirrors real-world distributed environments where clusters run across **different hardware architectures**.

---

# Target Cluster Architecture

After completing this guide, the cluster should look like this:

```id="clusterlayout"
Kubernetes Cluster
│
├── Control Plane
│   ├── k8s-master-1 (192.168.1.100)
│   └── k8s-master-2 (192.168.1.101)
│
└── Worker Nodes
    ├── pi5-1 (192.168.1.20)
    ├── pi5-2 (192.168.1.21)
    ├── pi5-3 (192.168.1.22)
    └── pi5-4 (192.168.1.23)
```

This cluster will later run:

* LLM inference containers
* Edge AI workloads
* Monitoring services
* Benchmarking tools

---

# Step 1 – Prepare All Nodes

Run the following on **all nodes** (VMs and Raspberry Pi).

Disable swap:

```bash id="disableswap"
sudo swapoff -a
```

Remove swap from fstab:

```bash id="removefstab"
sudo sed -i '/swap/d' /etc/fstab
```

Update system packages:

```bash id="updatesystem"
sudo apt update && sudo apt upgrade -y
```

---

# Step 2 – Install k3s on the First Control Plane Node

Login to:

```id="master1"
k8s-master-1
```

Install k3s:

```bash id="installk3s"
curl -sfL https://get.k3s.io | sh -
```

Check cluster status:

```bash id="checknodes"
sudo kubectl get nodes
```

You should see:

```id="firstnode"
k8s-master-1   Ready
```

---

# Step 3 – Retrieve the Cluster Join Token

On the control plane node:

```bash id="gettoken"
sudo cat /var/lib/rancher/k3s/server/node-token
```

Save this token for joining additional nodes.

Example:

```id="exampletoken"
K10c8bce1c...
```

---

# Step 4 – Add the Second Control Plane Node

Login to:

```id="master2"
k8s-master-2
```

Run the following command:

```bash id="joinmaster"
curl -sfL https://get.k3s.io | \
K3S_URL=https://192.168.1.100:6443 \
K3S_TOKEN=<NODE_TOKEN> \
sh -
```

Verify nodes:

```bash id="verifycontrolplane"
sudo kubectl get nodes
```

Expected output:

```id="expectedmasters"
k8s-master-1   Ready
k8s-master-2   Ready
```

---

# Step 5 – Join Raspberry Pi Worker Nodes

Run the following command on **each Raspberry Pi**.

Example for `pi5-1`:

```bash id="joinworker"
curl -sfL https://get.k3s.io | \
K3S_URL=https://192.168.1.100:6443 \
K3S_TOKEN=<NODE_TOKEN> \
sh -
```

Repeat for:

* pi5-2
* pi5-3
* pi5-4

---

# Step 6 – Verify Cluster Nodes

From **k8s-master-1**:

```bash id="checkcluster"
kubectl get nodes -o wide
```

Example output:

```id="clusternodes"
NAME           STATUS   ROLES           INTERNAL-IP
k8s-master-1   Ready    control-plane   192.168.1.100
k8s-master-2   Ready    control-plane   192.168.1.101
pi5-1          Ready    <none>          192.168.1.20
pi5-2          Ready    <none>          192.168.1.21
pi5-3          Ready    <none>          192.168.1.22
pi5-4          Ready    <none>          192.168.1.23
```

---

# Step 7 – Configure kubectl Access

Copy the kubeconfig to your user directory:

```bash id="copyconfig"
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
```

Test access:

```bash id="kubectltest"
kubectl get nodes
```

---

# Step 8 – Label Cluster Nodes

Label nodes based on architecture and role.

Label Raspberry Pi nodes:

```bash id="labelarm"
kubectl label node pi5-1 arch=arm64
kubectl label node pi5-2 arch=arm64
kubectl label node pi5-3 arch=arm64
kubectl label node pi5-4 arch=arm64
```

Label x86 nodes:

```bash id="labelamd"
kubectl label node k8s-master-1 arch=amd64
kubectl label node k8s-master-2 arch=amd64
```

Designate the edge AI node:

```bash id="labeledge"
kubectl label node pi5-4 edge-ai=true
```

Verify labels:

```bash id="checklabels"
kubectl get nodes --show-labels
```

---

# Step 9 – Test Cluster Scheduling

Create a simple test pod.

```bash id="testpod"
kubectl run nginx-test --image=nginx --port=80
```

Verify pod status:

```bash id="checkpods"
kubectl get pods -o wide
```

You should see the pod scheduled on one of the worker nodes.

Delete test pod:

```bash id="deletepod"
kubectl delete pod nginx-test
```

---

# Step 10 – Install Helm (Optional but Recommended)

Helm simplifies application deployment.

Install Helm:

```bash id="installhelm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify installation:

```bash id="helmversion"
helm version
```

---

# Verification Checklist

Confirm the following:

* Both control-plane nodes are running
* All Raspberry Pi workers joined the cluster
* kubectl works locally
* Node labels applied correctly
* Test pod deployed successfully

Cluster should now contain **6 nodes total**.

---

# Resulting Kubernetes Environment

```id="finalcluster"
2 Control Plane Nodes (x86)
4 Worker Nodes (ARM)

Mixed Architecture Kubernetes Cluster
```

This cluster will run:

* LLM inference workloads
* Edge AI containers
* Monitoring stack
* Load testing and benchmarking tools

---

# Next Step

Proceed to:

```id="nextdeploy"
docs/setup/05-docker-llm-deployment.md
```

In the next guide we will deploy **local LLM containers** using Docker and Kubernetes, which will allow benchmarking and AI inference workloads inside the homelab cluster.
