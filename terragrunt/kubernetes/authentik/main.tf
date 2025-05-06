resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }
}

# Create ServiceAccount for Vault Auth
resource "kubernetes_service_account" "authentik_vault" {
  metadata {
    name      = "authentik-vault"
    namespace = kubernetes_namespace.authentik.metadata[0].name
  }
}

# Configure Secret with Vault annotations
resource "kubernetes_secret" "authentik_secrets" {
  metadata {
    name      = "authentik-secrets"
    namespace = kubernetes_namespace.authentik.metadata[0].name
    annotations = {
      "vault.hashicorp.com/agent-inject"                               = "true"
      "vault.hashicorp.com/role"                                       = "authentik"
      "vault.hashicorp.com/agent-inject-secret-authentik-secret-key"   = "secret/data/TKA-Authentik-secret-key"
      "vault.hashicorp.com/agent-inject-template-authentik-secret-key" = <<-EOT
        {{- with secret "secret/data/TKA-Authentik-secret-key" -}}
        {{ .Data.data.password }}
        {{- end -}}
      EOT
      "vault.hashicorp.com/agent-inject-secret-postgresql-password"    = "secret/data/TKA-Authentik-postgresql-password"
      "vault.hashicorp.com/agent-inject-template-postgresql-password"  = <<-EOT
        {{- with secret "secret/data/TKA-Authentik-postgresql-password" -}}
        {{ .Data.data.password }}
        {{- end -}}
      EOT
      "vault.hashicorp.com/agent-inject-secret-smtp-password"          = "secret/data/TKA-Authentik-smtp-password"
      "vault.hashicorp.com/agent-inject-template-smtp-password"        = <<-EOT
        {{- with secret "secret/data/TKA-Authentik-smtp-password" -}}
        {{ .Data.data.password }}
        {{- end -}}
      EOT
    }
  }

  # Importante: adicione valores iniciais para as chaves
  data = {
    "authentik-secret-key" = "placeholder-will-be-replaced-by-vault"
    "postgresql-password"  = "placeholder-will-be-replaced-by-vault"
    "smtp-password"        = "placeholder-will-be-replaced-by-vault"
  }

  type = "Opaque"
}

# Create Vault policy and role for Authentik
resource "null_resource" "vault_policy_and_role" {
  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -e
      
      # Set VAULT_ADDR to the correct value
      export VAULT_ADDR="http://vault.localdomain:8200"
      
      # Check if VAULT_TOKEN is defined
      if [ -z "$${VAULT_TOKEN}" ]; then
        echo "Error: VAULT_TOKEN is not defined. Please export the VAULT_TOKEN environment variable."
        exit 1
      fi
      
      # Create a Vault policy for Authentik
      vault policy write authentik - <<EOF
path "secret/data/TKA-Authentik-*" {
  capabilities = ["read"]
}
EOF
      
      # Get ServiceAccount details
      VAULT_SA_NAME="authentik-vault"
      SA_JWT_TOKEN=$(kubectl get secret \
        $(kubectl get serviceaccount $${VAULT_SA_NAME} -n authentik -o jsonpath='{.secrets[0].name}') \
        -n authentik -o jsonpath='{.data.token}' | base64 --decode)
      
      # Create Kubernetes auth role for Authentik
      vault write auth/kubernetes/role/authentik \
        bound_service_account_names=$${VAULT_SA_NAME} \
        bound_service_account_namespaces=authentik \
        policies=authentik \
        ttl=1h
      
      echo "Vault policy and role created successfully"
    EOT
  }

  depends_on = [
    kubernetes_namespace.authentik,
    kubernetes_service_account.authentik_vault
  ]
}

resource "helm_release" "authentik" {
  name       = "authentik"
  repository = "https://charts.goauthentik.io"
  chart      = "authentik"
  version    = "2025.4.0"
  namespace  = kubernetes_namespace.authentik.metadata[0].name
  timeout    = 600

  values = [<<EOF
global:
  env:
    - name: AUTHENTIK_SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: authentik-secrets
          key: authentik-secret-key
    - name: AUTHENTIK_EMAIL__PASSWORD
      valueFrom:
        secretKeyRef:
          name: authentik-secrets
          key: smtp-password
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: authentik-secrets
          key: postgresql-password

authentik:
  email:
    host: "smtp.mailgun.org"
    port: 587
    username: "postmaster@mg.tkasolutions.com.br"
    use_tls: true
    from: "postmaster@mg.tkasolutions.com.br"

server:
  podAnnotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/agent-pre-populate-only: "true" 
    vault.hashicorp.com/role: "authentik"
    vault.hashicorp.com/agent-run-as-user: "0"
    vault.hashicorp.com/agent-inject-status: "update"
    vault.hashicorp.com/namespace: ""
    vault.hashicorp.com/auth-path: "auth/kubernetes"
    vault.hashicorp.com/agent-service-address: "http://vault.localdomain:8200"
    vault.hashicorp.com/secret-volume-path: "/vault/secrets"
  extraVolumeMounts:
    - name: vault-secrets
      mountPath: /vault/secrets
      readOnly: true
  extraVolumes:
    - name: vault-secrets
      emptyDir: 
        medium: Memory
  serviceAccount:
    create: false
    name: "authentik-vault"
  ingress:
    ingressClassName: traefik
    enabled: true
    hosts:
      - auth.tkasolutions.com.br

postgresql:
  enabled: true
  auth:
    existingSecret: authentik-secrets
    secretKeys: 
      userPasswordKey: postgresql-password
  serviceAccount:
    create: false
    name: "authentik-vault"
  primary:
    podAnnotations:
      vault.hashicorp.com/agent-inject: "true"
      vault.hashicorp.com/agent-pre-populate-only: "true"
      vault.hashicorp.com/role: "authentik"
      vault.hashicorp.com/agent-run-as-user: "0"
      vault.hashicorp.com/agent-inject-status: "update"
      vault.hashicorp.com/namespace: ""
      vault.hashicorp.com/auth-path: "auth/kubernetes"
      vault.hashicorp.com/agent-service-address: "http://vault.localdomain:8200"

redis:
  enabled: true
EOF
  ]

  depends_on = [
    kubernetes_namespace.authentik,
    kubernetes_secret.authentik_secrets,
    kubernetes_service_account.authentik_vault,
    null_resource.vault_policy_and_role
  ]
}
