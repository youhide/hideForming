terraform {
  required_version = "1.3.5"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
  cloud {
    organization = "YouHide"
    workspaces {
      name = "main"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.11.216:8006/api2/json"
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}
