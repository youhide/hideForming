resource "proxmox_lxc" "terraform_cloud_agent" {
  target_node  = "pve2"
  hostname     = "tfc-agent.localdomain"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores        = 2
  memory       = 1024
  password     = "something"
  unprivileged = true
  start        = true
  onboot       = true
  ostype       = "ubuntu"
  pool         = "Backup"

  ssh_public_keys = <<-EOT
    ${var.youri_ssh_public_key}
  EOT

  features {
    nesting = true
  }

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = var.proxmox_vlan_bridge
    ip     = "dhcp"
  }
}
