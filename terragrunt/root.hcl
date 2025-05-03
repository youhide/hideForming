locals {
  workspace         = reverse(split("/", get_terragrunt_dir()))[0]
  
  pm_api_token_id = get_env("TF_VAR_proxmox_token_id", "not_found")
  pm_api_token_secret = get_env("TF_VAR_proxmox_token_secret", "not_found")
  
  s3_bucket_name = "tfstate"
  s3_key = get_env("TF_VAR_s3_access_key", "not_found")
  s3_secret_key = get_env("TF_VAR_s3_secret_key", "not_found")
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
    use_path_style              = true
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
