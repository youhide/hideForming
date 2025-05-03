variable "enabled" {
  description = "Enable or disable the module"
  type        = bool
  default     = true
}

variable "proxmox_lxc_parameters" {
  description = "Proxmox LXC parameters"
  type = list(object({
    target_node = string
    hostname    = string
    ostemplate  = string
    password    = string
    cpus        = number
    memory      = number
    # swap            = number
    unprivileged    = bool
    start           = bool
    onboot          = bool
    ostype          = string
    pool            = string
    ssh_public_keys = string
    nesting         = bool
    disk_size       = string
    storage         = string
    # network_type    = string
    network_bridge = string
  }))
  default = [{
    target_node = "pveopti"
    hostname    = null
    ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    password    = "something"
    cpus        = null
    memory      = null
    # swap            = null
    unprivileged    = true
    ostype          = "ubuntu"
    pool            = ""
    ssh_public_keys = ""
    nesting         = true
    start           = true
    onboot          = true
    disk_size       = "16G"
    storage         = "local"
    # network_type    = "virtio"
    network_bridge = "vmbr0"
  }]
}
