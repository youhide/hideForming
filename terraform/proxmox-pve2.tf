resource "proxmox_lxc" "cronbox_lxc" {
  target_node  = "pve2"
  hostname     = "cronbox.localdomain"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = "something"
  unprivileged = true
  start        = true
  ostype       = "ubuntu"

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1iC2EQeFQqN0kVZeTX4ID5wMaUZbId318umCxP37gm Youri@MacBook-Pro
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr70"
    ip     = "dhcp"
  }
}
