# resource "proxmox_lxc" "basic" {
#   target_node  = "pve2"
#   hostname     = "lxc-basic"
#   ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
#   password     = "BasicLXCContainer"
#   unprivileged = true

#   // Terraform will crash without rootfs defined
#   rootfs {
#     storage = "local-lvm"
#     size    = "8G"
#   }

#   network {
#     name   = "eth0"
#     bridge = "vmbr0"
#     ip     = "dhcp"
#   }
# }
