# hideForming - Infrastructure as Code Repository

<p align="center">
  <img src="https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white" alt="Ansible">
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/OpenTofu-5956E9?style=for-the-badge&logo=opentofu&logoColor=white" alt="OpenTofu">
  <img src="https://img.shields.io/badge/Terragrunt-2F7589?style=for-the-badge&logo=terragrunt&logoColor=white" alt="Terragrunt">
  <img src="https://img.shields.io/badge/Vault-000000?style=for-the-badge&logo=vault&logoColor=white" alt="Vault">
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" alt="Kubernetes">
</p>

## Overview

hideForming is a comprehensive Infrastructure as Code (IaC) repository that manages a complete homelab environment using modern DevOps practices. The project leverages multiple complementary technologies to create a robust, scalable, and secure infrastructure foundation:

- **Configuration Management**: Ansible automates the deployment and configuration of services like Vault, Atlantis, and game servers, ensuring consistent environments and reducing manual intervention.

- **Infrastructure Provisioning**: OpenTofu/Terraform with Terragrunt enables declarative infrastructure definitions with improved modularity and environment segregation. This approach ensures reliable, repeatable deployments across different environments.

- **Secrets Management**: HashiCorp Vault provides a centralized secrets store with secure access controls. The External Secrets Operator connects Kubernetes workloads with Vault, enabling secure secret injection into applications.

- **Security**: The implementation includes Authentik for identity and access management, integrating with CloudFlare Zero Trust Gateway to provide fine-grained network security controls.

- **GitOps Workflow**: Atlantis facilitates infrastructure changes through pull requests, enforcing peer review and providing visibility into infrastructure modifications before they are applied.

The repository follows infrastructure-as-code best practices, including modularization, version control, and the principle of least privilege, making it suitable for production environments while remaining flexible enough for homelab experimentation.

## Repository Structure

- **ansible/**: Ansible playbooks and roles for configuration management
  - **playbooks/**: Task definitions for different services
    - **atlantis.yml**: GitOps workflow for Terraform/OpenTofu
    - **cronbox.yml**: Scheduled tasks configuration
    - **vault.yml**: HashiCorp Vault installation and setup
    - **legend-database.yml**: Database configuration for Legend
    - **legend-shard.yml**: Shard configuration for Legend
    - **terraform-agent.yml**: Terraform/OpenTofu agent configuration
    - **toolbox-ubuntu.yml**: Ubuntu-based toolbox setup
  - **roles/**: Reusable roles for various components
    - **atlantis/**: GitOps workflow configuration
    - **vault/**: Secrets management setup
    - **docker/**: Docker installation and configuration
    - **external-secrets-operator/**: Kubernetes secrets integration
    - **cronbox/**: Cron jobs management including CloudFlare Zero Trust Gateway updates
  - **environments/**: Environment-specific configurations
    - **hosts**: Inventory file for Ansible
    - **cross_vars.yml**: Cross-environment variables

- **modules/**: Reusable Terraform/OpenTofu modules
  - **terraform/**: Custom modules
    - **minio/**: Module for MinIO object storage
    - **proxmox-lxc/**: Module for Proxmox LXC containers

- **terragrunt/**: Terragrunt configurations for different environments
  - **kubernetes/**: Kubernetes-related resources
    - **authentik/**: Identity and access management
    - **renovate/**: Dependency updates automation
    - **vault/**: Secrets management configuration
  - **openmediavault/**: OpenMediaVault-related resources
    - **minio/**: MinIO object storage deployment
  - **proxmox/**: Proxmox-related resources
    - **dummy/**: Template configuration for new VMs

## Key Components

- **Vault**: Securely store and manage secrets
- **External Secrets Operator**: Kubernetes integration for Vault secrets
- **Authentik**: Identity and access management solution
- **Atlantis**: GitOps workflow for OpenTofu/Terraform
- **Renovate**: Automated dependency updates
- **Kubernetes**: Container orchestration
- **Proxmox**: Virtualization platform
- **OpenMediaVault**: Network-attached storage
- **CloudFlare Zero Trust Gateway**: Network security
- **Legend**: Game server management (database and shards)

## Contributing

If you want to contribute to this repository, please fork the repository and submit a pull request.

## License

This repository is licensed under the MIT License. See the LICENSE file for more information.
