resource "kubernetes_namespace" "vault" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

# Vault Agent Injector Deployment
resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.vault_chart_version
  namespace  = var.create_namespace ? kubernetes_namespace.vault[0].metadata[0].name : var.namespace
  timeout    = 600

  values = [
    <<EOF
global:
  enabled: true

injector:
  enabled: true
  replicas: 1

server:
  enabled: false  # Does not deploy a Vault server, only the agent
  
  # Define the external Vault
  externalConfig:
    enabled: true
    addr: "${var.vault_server}"

  serviceAccount:
    create: true
EOF
  ]

  depends_on = [
    kubernetes_namespace.vault
  ]
}

# Configure Vault to recognize Kubernetes
resource "null_resource" "configure_vault_kubernetes" {
  depends_on = [helm_release.vault]

  # Trigger whenever Helm release changes
  triggers = {
    helm_revision = helm_release.vault.status
  }

  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -e

      # Check if VAULT_TOKEN is defined
      if [ -z "$VAULT_TOKEN" ]; then
        echo "Error: VAULT_TOKEN is not defined. Please export the VAULT_TOKEN environment variable."
        exit 1
      fi

      # Check if VAULT_UNSEAL_KEY is defined
      if [ -z "$VAULT_UNSEAL_KEY" ]; then
        echo "Error: VAULT_UNSEAL_KEY is not defined. Please export the VAULT_UNSEAL_KEY environment variable."
        exit 1
      fi
      
      # Check Vault status
      echo "Checking Vault status..."
      VAULT_STATUS=$(curl -s ${var.vault_server}/v1/sys/seal-status | grep -o '"sealed":[^,]*' | cut -d: -f2)
      
      # If Vault is sealed, unseal it
      if [ "$VAULT_STATUS" = "true" ]; then
        echo "Vault is sealed. Performing unseal..."
        curl -s \
          --request PUT \
          --data "{\"key\": \"$VAULT_UNSEAL_KEY\"}" \
          ${var.vault_server}/v1/sys/unseal
        
        # Check status again
        sleep 2
        VAULT_STATUS=$(curl -s ${var.vault_server}/v1/sys/seal-status | grep -o '"sealed":[^,]*' | cut -d: -f2)
        
        if [ "$VAULT_STATUS" = "true" ]; then
          echo "Error: Could not unseal Vault."
          exit 1
        else
          echo "Vault successfully unsealed."
        fi
      else
        echo "Vault is already unsealed."
      fi
      
      # Configure Kubernetes authentication in Vault
      echo "Enabling Kubernetes authentication method..."
      curl -s \
        --header "X-Vault-Token: $VAULT_TOKEN" \
        --request POST \
        --data '{"type": "kubernetes"}' \
        ${var.vault_server}/v1/sys/auth/kubernetes || echo "Kubernetes authentication method already enabled"
        
      echo "Kubernetes authentication successfully configured in Vault"
    EOT

    environment = {
      VAULT_ADDR = var.vault_server
    }
  }
}
