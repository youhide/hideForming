output "containers" {
  description = "Information about all created Proxmox LXC containers"
  value = length(proxmox_lxc.container) > 0 ? {
    for name, container in proxmox_lxc.container : name => {
      id           = container.id
      hostname     = container.hostname
      target_node  = container.target_node
      ip_address   = container.network[0].ip
      memory       = container.memory
      cores        = container.cores
      unprivileged = container.unprivileged
      vmid         = container.vmid
    }
  } : null
}
