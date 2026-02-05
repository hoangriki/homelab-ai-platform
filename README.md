# Homelab AI Platform

This project demonstrates a mixed-architecture homelab using:
- Proxmox for virtualization
- Docker for containerization
- Kubernetes (k3s) for orchestration
- Terraform for infrastructure as code
- Edge AI (Raspberry Pi + AI HAT Plus)
- Local LLM inference and benchmarking

## Hardware
- 2× HP Z1 Mini (Proxmox hosts)
- 4× Raspberry Pi 5 (k3s workers)
- 1× AI HAT Plus (edge inference)

## Architecture

![image0](https://github.com/user-attachments/assets/da4ba8cc-08d5-4f78-be32-fa89e6f4bfd3)


## Goals
- Run and benchmark LLMs locally
- Deploy edge AI workloads
- Practice production-style infra patterns
- Learn heterogeneous compute scheduling

