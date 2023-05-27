# hideForming Terraform

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.4.6 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 2.9.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 2.9.14 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_lxc.cronbox_lxc](https://registry.terraform.io/providers/telmate/proxmox/2.9.14/docs/resources/lxc) | resource |
| [proxmox_lxc.terraform_cloud_agent](https://registry.terraform.io/providers/telmate/proxmox/2.9.14/docs/resources/lxc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_proxmox_api_token_id"></a> [proxmox\_api\_token\_id](#input\_proxmox\_api\_token\_id) | The ID of the Proxmox API token | `string` | n/a | yes |
| <a name="input_proxmox_api_token_secret"></a> [proxmox\_api\_token\_secret](#input\_proxmox\_api\_token\_secret) | The secret of the Proxmox API token | `string` | n/a | yes |
| <a name="input_proxmox_vlan_bridge"></a> [proxmox\_vlan\_bridge](#input\_proxmox\_vlan\_bridge) | The name of the Proxmox VLAN bridge | `string` | `"vmbr70"` | no |
| <a name="input_youri_ssh_public_key"></a> [youri\_ssh\_public\_key](#input\_youri\_ssh\_public\_key) | Youri's SSH public key | `string` | `"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1iC2EQeFQqN0kVZeTX4ID5wMaUZbId318umCxP37gm Youri@MacBook-Pro"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
