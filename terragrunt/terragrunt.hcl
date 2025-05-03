locals {
  workspace         = reverse(split("/", get_terragrunt_dir()))[0]

  pm_api_token_id     = run_cmd("pass", "hideOut/Terraform/Proxmox/token_id")
  pm_api_token_secret = run_cmd("pass", "hideOut/Terraform/Proxmox/token_secret")

  s3_bucket_name    = "tfstate"
  s3_key            = run_cmd("pass", "hideOut/OpenMediaVault/s3/access_key")
  s3_secret_key     = run_cmd("pass", "hideOut/OpenMediaVault/s3/secret_key")
}

generate "remote_state" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_version = "1.9.1"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }

  backend "s3" {
    bucket = "tfstate"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
    
    endpoint                    = "http://openmediavault.localdomain:9000"
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    
    access_key = "${local.s3_key}"
    secret_key = "${local.s3_secret_key}"
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.11.108:8006/api2/json"
  pm_api_token_id     = "${local.pm_api_token_id}"
  pm_api_token_secret = "${local.pm_api_token_secret}"
  pm_tls_insecure     = true
}  
EOF
}
