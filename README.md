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

## Architecture:

![image0](https://github.com/user-attachments/assets/88c346f5-82c1-4173-8455-a1191fc1a31c)

## AWS Cloud deployment:

<img width="647" height="465" alt="1_EEfcVBjRwGTNkDuyPpciHQ" src="https://github.com/user-attachments/assets/f460bde7-1096-4e19-a013-175b1d41aada" />


## Goals
- Run and benchmark LLMs locally
- Deploy edge AI workloads
- Practice production-style infra patterns
- Learn heterogeneous compute scheduling
- Deploy to the cloud
