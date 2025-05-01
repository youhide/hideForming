include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/terraform/proxmox-lxc"
}

inputs = {
  proxmox_lxc_parameters = [
    {
      hostname        = "cronbox"
      ostemplate      = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      cpus            = 1
      memory          = 512
      ostype          = "ubuntu"
      ssh_public_keys = "asd"
      disk_size       = "8G"
    },
    {
      hostname        = "cronbox2"
      ostemplate      = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      cpus            = 1
      memory          = 512
      ostype          = "ubuntu"
      ssh_public_keys = "asd"
      disk_size       = "8G"
    }
  ]
}
