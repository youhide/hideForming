# resource "proxmox_lxc" "container" {
#   for_each = { for param in var.proxmox_lxc_parameters : param.hostname => param }

#   target_node  = each.value.target_node
#   hostname     = each.value.hostname
#   ostemplate   = each.value.ostemplate
#   password     = each.value.password
#   cores        = each.value.cpus
#   memory       = each.value.memory
#   unprivileged = each.value.unprivileged
#   start        = each.value.start
#   onboot       = each.value.onboot
#   ostype       = each.value.ostype
#   pool         = each.value.pool

#   ssh_public_keys = <<-EOT
#     ${each.value.ssh_public_keys}
#   EOT

#   features {
#     nesting = each.value.nesting
#   }

#   // Terraform will crash without rootfs defined
#   rootfs {
#     storage = "local-lvm"
#     size    = "${each.value.disk_size}"
#   }

#   network {
#     name   = "eth0"
#     bridge = "${each.value.network_bridge}"
#     ip     = "dhcp"
#   }
# }



resource "proxmox_lxc" "container" {
  target_node  = var.proxmox_lxc_parameters[*].target_node
  hostname     = var.proxmox_lxc_parameters[*].hostname
  ostemplate   = var.proxmox_lxc_parameters[*].ostemplate
  password     = var.proxmox_lxc_parameters[*].password
  cores        = var.proxmox_lxc_parameters[*].cpus
  memory       = var.proxmox_lxc_parameters[*].memory
  unprivileged = var.proxmox_lxc_parameters[*].unprivileged
  start        = var.proxmox_lxc_parameters[*].start
  onboot       = var.proxmox_lxc_parameters[*].onboot
  ostype       = var.proxmox_lxc_parameters[*].ostype
  pool         = var.proxmox_lxc_parameters[*].pool

  ssh_public_keys = <<-EOT
    ${var.proxmox_lxc_parameters[*].ssh_public_keys}
  EOT

  features {
    nesting = var.proxmox_lxc_parameters[*].nesting
  }

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "${var.proxmox_lxc_parameters[*].disk_size}"
  }

  network {
    name   = "eth0"
    bridge = "${var.proxmox_lxc_parameters[*].network_bridge}"
    ip     = "dhcp"
  }
}
