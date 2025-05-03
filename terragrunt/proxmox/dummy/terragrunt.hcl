include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/terraform/proxmox-lxc"
}

inputs = {
  enabled = true
  proxmox_lxc_parameters = [
    {
      target_node     = "pveopti"
      hostname        = "dummy"
      ostemplate      = "omv-backup:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      password        = "something"
      cpus            = 1
      memory          = 512
      unprivileged    = true
      start           = true
      onboot          = true
      ostype          = "ubuntu"
      pool            = ""
      ssh_public_keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEOfnkTH5m3GIpdxSJzzyUv2KpuNFoPCf5XCwvy/1eA"
      nesting         = true
      disk_size       = "8G"
      storage         = "local-lvm-ssd"
      network_bridge  = "vmbr0"
    }
  ]
}
