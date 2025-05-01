locals {
  tfc_hostname     = "app.terraform.io" # For TFE, substitute the custom hostname for your TFE host
  tfc_organization = "YouHide"
  workspace        = reverse(split("/", get_terragrunt_dir()))[0] # This will find the name of the module, such as "sqs"
}

generate "remote_state" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_version = "1.8.3"
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }

  backend "remote" {
    hostname = "${local.tfc_hostname}"
    organization = "${local.tfc_organization}"
    workspaces {
      name = "${local.workspace}"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.11.108:8006/api2/json"
  pm_api_token_id     = "${get_env("TF_VAR_proxmox_api_token_id", "")}"
  pm_api_token_secret = "${get_env("TF_VAR_proxmox_api_token_secret", "")}"
}  
EOF
}
