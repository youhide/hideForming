resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name = "longhorn-system"
  }
}

resource "vault_generic_secret" "longhorn_secrets" {
  path = "secret/TF-Longhorn-s3-keys"
  data_json = jsonencode({
    "access-key"           = var.bucket_access_key,
    "secret-key"           = var.bucket_secret_key,
    "endpoint"             = "http://openmediavault.localdomain:9000/"
    "virtual_hosted_style" = true
  })
}

resource "kubernetes_manifest" "longhorn_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "longhorn-vault-secrets"
      namespace = kubernetes_namespace.longhorn_system.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "vault-backend"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "longhorn-secrets"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "AWS_ACCESS_KEY_ID"
          remoteRef = {
            key      = "secret/TF-Longhorn-s3-keys"
            property = "access-key"
          }
        },
        {
          secretKey = "AWS_SECRET_ACCESS_KEY"
          remoteRef = {
            key      = "secret/TF-Longhorn-s3-keys"
            property = "secret-key"
          }
        },
        {
          secretKey = "AWS_ENDPOINTS"
          remoteRef = {
            key      = "secret/TF-Longhorn-s3-keys"
            property = "endpoint"
          }
        },
        {
          secretKey = "VIRTUAL_HOSTED_STYLE"
          remoteRef = {
            key      = "secret/TF-Longhorn-s3-keys"
            property = "virtual_hosted_style"
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_namespace.longhorn_system
  ]
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.8.1"
  namespace  = kubernetes_namespace.longhorn_system.metadata[0].name
  timeout    = 600

  values = [<<EOF
defaultBackupStore:
  backupTarget: s3://longhorn@us-east-1/
  backupTargetCredentialSecret: longhorn-secrets
longhornUI:
  replicas: 1
  EOF
  ]

  depends_on = [
    kubernetes_namespace.longhorn_system,
    kubernetes_manifest.longhorn_external_secret
  ]
}
