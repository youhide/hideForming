resource "proxmox_lxc" "container" {
  for_each = var.enabled ? { for idx, param in var.proxmox_lxc_parameters : param.hostname != null ? param.hostname : "container-${idx}" => param } : {}

  target_node  = each.value.target_node
  hostname     = each.value.hostname
  ostemplate   = each.value.ostemplate
  password     = each.value.password
  cores        = each.value.cpus
  memory       = each.value.memory
  unprivileged = each.value.unprivileged
  start        = each.value.start
  onboot       = each.value.onboot
  ostype       = each.value.ostype
  pool         = each.value.pool

  ssh_public_keys = <<-EOT
    ${each.value.ssh_public_keys}
  EOT

  features {
    nesting = each.value.nesting
  }

  // Terraform will crash without rootfs defined
  rootfs {
    storage = each.value.storage
    size    = each.value.disk_size
  }

  network {
    name   = "eth0"
    bridge = each.value.network_bridge
    ip     = "dhcp"
  }
}
