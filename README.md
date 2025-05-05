# HideForming - Infrastructure as Code Repository

<p align="center">
  <img src="https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white" alt="Ansible">
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/Terragrunt-2F7589?style=for-the-badge&logo=terragrunt&logoColor=white" alt="Terragrunt">
  <img src="https://img.shields.io/badge/Vault-000000?style=for-the-badge&logo=vault&logoColor=white" alt="Vault">
</p>

## Overview

HideForming is a comprehensive Infrastructure as Code (IaC) repository that manages a complete homelab environment using modern DevOps practices. The project uses Ansible for configuration management, Terraform/Terragrunt for infrastructure provisioning, and HashiCorp Vault for secrets management.

## Repository Structure

- **ansible/**: Ansible playbooks and roles for configuration management
  - **playbooks/**: Task definitions for different services
  - **roles/**: Reusable roles for various components
  - **environments/**: Environment-specific configurations

- **modules/**: Reusable Terraform modules
  - **terraform/**: Custom Terraform modules
    - **kubernetes-vault/**: Module for Vault integration with Kubernetes
    - **minio/**: Module for MinIO object storage
    - **proxmox-lxc/**: Module for Proxmox LXC containers

- **terragrunt/**: Terragrunt configurations for different environments
  - **kubernetes/**: Kubernetes-related resources
  - **openmediavault/**: OpenMediaVault-related resources
  - **proxmox/**: Proxmox-related resources

## Key Components

- **Vault**: Securely store and manage secrets
- **Atlantis**: GitOps workflow for Terraform
- **Kubernetes**: Container orchestration
- **Proxmox**: Virtualization platform
- **OpenMediaVault**: Network-attached storage

## Getting Started

### Prerequisites

- Ansible 2.9+
- Terraform 1.0+
- Terragrunt 0.36+
- Vault CLI
- Access to target environment

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/youhide/hideForming.git
   cd hideForming
   ```

2. Run Ansible playbooks:
   ```bash
   cd ansible
   make vault
   ```

3. Deploy infrastructure with Terragrunt:
   ```bash
   cd terragrunt/kubernetes/vault
   export VAULT_TOKEN=$(pass show hideOut/Vault/root_token)
   export VAULT_UNSEAL_KEY=$(pass show hideOut/Vault/unseal_key)
   terragrunt apply
   ```

## Contributing

If you want to contribute to this repository, please fork the repository and submit a pull request.

## License

This repository is licensed under the MIT License. See the LICENSE file for more information.
