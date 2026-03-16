# 08 – Terraform Infrastructure Automation

## Overview

This guide introduces **Terraform Infrastructure as Code (IaC)** for managing your homelab environment.

Terraform will allow you to:

* Provision **Proxmox virtual machines**
* Manage **Kubernetes resources**
* Deploy **LLM workloads**
* Maintain **reproducible infrastructure**

This mirrors how DevOps teams manage **cloud infrastructure in production environments**.

Instead of manually creating VMs or deployments, Terraform will define infrastructure using code.

---

# Terraform Architecture in the Homelab

Terraform will control multiple infrastructure layers.

```id="tfarch"
Terraform
│
├── Proxmox Infrastructure
│   ├── Kubernetes VMs
│   └── Benchmarking VM
│
├── Kubernetes Resources
│   ├── Namespaces
│   ├── Deployments
│   └── Services
│
└── AI Workloads
    ├── LLM Deployments
    └── Monitoring Components
```

This enables **fully automated environment provisioning**.

---

# Step 1 – Install Terraform

Install Terraform on your control-plane VM or workstation.

Ubuntu example:

```bash id="installtf"
sudo apt update
sudo apt install -y gnupg software-properties-common curl

curl -fsSL https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform
```

Verify installation:

```bash id="checktf"
terraform version
```

Example output:

```id="tfversion"
Terraform v1.x.x
```

---

# Step 2 – Create Terraform Directory Structure

Inside the repository:

```id="tfdir"
terraform/
│
├── proxmox/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── kubernetes/
│   ├── namespaces.tf
│   ├── llm-deployment.tf
│   └── services.tf
│
└── providers.tf
```

This structure separates infrastructure layers.

---

# Step 3 – Configure Terraform Providers

Create:

```id="providersfile"
terraform/providers.tf
```

Example configuration:

```hcl id="providerscode"
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">=2.9"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
```

This allows Terraform to interact with:

* Proxmox virtualization
* Kubernetes API

---

# Step 4 – Configure Proxmox Provider

Create:

```id="proxmain"
terraform/proxmox/main.tf
```

Example configuration:

```hcl id="proxcode"
provider "proxmox" {
  pm_api_url  = "https://192.168.1.10:8006/api2/json"
  pm_user     = "root@pam"
  pm_password = var.proxmox_password
  pm_tls_insecure = true
}
```

Define variables.

```id="varfile"
terraform/proxmox/variables.tf
```

Example:

```hcl id="varcode"
variable "proxmox_password" {
  type = string
  sensitive = true
}
```

---

# Step 5 – Define a Virtual Machine

Example VM definition.

```hcl id="vmexample"
resource "proxmox_vm_qemu" "k8s_worker" {

  name        = "k8s-worker-terraform"
  target_node = "z1-1"

  clone = "ubuntu-template"

  cores  = 4
  memory = 8192

  disk {
    size = "40G"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
}
```

Terraform will now be able to **create Kubernetes worker VMs automatically**.

---

# Step 6 – Initialize Terraform

Navigate to the Terraform directory.

```bash id="tfinit"
cd terraform
terraform init
```

Terraform will download required providers.

Example output:

```id="tfinitout"
Terraform has been successfully initialized
```

---

# Step 7 – Validate Configuration

Run validation to check configuration.

```bash id="tfvalidate"
terraform validate
```

Expected result:

```id="tfvalidateout"
Success! The configuration is valid.
```

---

# Step 8 – Create Infrastructure Plan

Generate an execution plan.

```bash id="tfplan"
terraform plan
```

Example output:

```id="tfplanout"
Plan: 1 to add, 0 to change, 0 to destroy.
```

This shows what Terraform will create.

---

# Step 9 – Apply Infrastructure

Deploy infrastructure.

```bash id="tfapply"
terraform apply
```

Confirm when prompted.

Terraform will:

* Create the VM
* Configure networking
* Provision infrastructure automatically

---

# Step 10 – Manage Kubernetes Resources with Terraform

Create:

```id="tfk8s"
terraform/kubernetes/namespaces.tf
```

Example namespace resource:

```hcl id="tfk8scode"
resource "kubernetes_namespace" "ai" {
  metadata {
    name = "ai"
  }
}
```

Example deployment resource:

```hcl id="tfdeploy"
resource "kubernetes_deployment" "llm" {
  metadata {
    name = "llama3"
    namespace = "ai"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "llama3"
      }
    }

    template {
      metadata {
        labels = {
          app = "llama3"
        }
      }

      spec {
        container {
          name  = "ollama"
          image = "ollama/ollama"

          port {
            container_port = 11434
          }
        }
      }
    }
  }
}
```

Terraform can now deploy **LLM workloads automatically**.

---

# Step 11 – Destroy Infrastructure (Optional)

Remove infrastructure if needed.

```bash id="tfdestroy"
terraform destroy
```

Terraform will safely delete managed resources.

---

# Verification Checklist

Confirm the following:

* Terraform installed
* Providers configured
* Infrastructure plan generated
* VM created successfully
* Kubernetes resources managed by Terraform

---

# Result

Your homelab now supports **Infrastructure as Code automation**.

```id="tfresult"
Terraform-managed VMs
Automated Kubernetes resources
Reproducible deployments
Version-controlled infrastructure
```

This workflow mirrors **real DevOps infrastructure pipelines used in cloud environments**.

---

# Next Step

Proceed to:

```id="finalstep"
docs/architecture/homelab-architecture.md
```

The final document will describe the **full architecture of the homelab**, including:

* cluster topology
* AI workloads
* monitoring infrastructure
* automation pipelines.
