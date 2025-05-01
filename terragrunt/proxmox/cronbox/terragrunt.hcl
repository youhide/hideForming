include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/terraform/proxmox-lxc"
}

inputs = {
  proxmox_lxc_parameters = [
    {
      target_node     = "pveopti"
      hostname        = "cronbox"
      ostemplate      = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      password        = "something"
      cpus            = 1
      memory          = 512
      unprivileged    = true
      start           = true
      onboot          = true
      ostype          = "ubuntu"
      pool            = ""
      ssh_public_keys = "asd"
      nesting         = true
      disk_size       = "8G"
      network_bridge  = "vmbr0"
    }
  ]
}
