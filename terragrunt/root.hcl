locals {
  workspace         = reverse(split("/", get_terragrunt_dir()))[0]
}

generate "remote_state" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_version = "1.9.1"
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "4.8.0"
    }  
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.36.0"
    }    
    helm = {
      source = "hashicorp/helm"
      version = "3.0.0-pre2"
    }    
    minio = {
      source = "aminueza/minio"
      version = "3.5.0"
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
  }
}

provider "vault" {
  address = "http://vault.localdomain:8200"
}

provider "proxmox" {
  pm_api_url          = "https://192.168.11.108:8006/api2/json"
  pm_tls_insecure     = true
}  

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider minio {
  minio_server   = "openmediavault.localdomain:9000"
}
EOF
}
