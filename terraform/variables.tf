variable "proxmox_api_token_id" {
  description = "The ID of the Proxmox API token"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "The secret of the Proxmox API token"
  type        = string
}

variable "proxmox_vlan_bridge" {
  description = "The name of the Proxmox VLAN bridge"
  type        = string
  default     = "vmbr70"
}

variable "youri_ssh_public_key" {
  description = "Youri's SSH public key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1iC2EQeFQqN0kVZeTX4ID5wMaUZbId318umCxP37gm Youri@MacBook-Pro"
}

