resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name = "longhorn-system"
  }
}

resource "vault_generic_secret" "longhorn_secrets" {
  path = "secret/TF-Longhorn-s3-keys"
  data_json = jsonencode({
    "access-key" = var.bucket_access_key,
    "secret-key" = var.bucket_secret_key,
    "endpoint"   = "http://openmediavault.localdomain:9000/"
  })
}

resource "kubernetes_manifest" "longhorn_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
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
        }
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }

  depends_on = [
    kubernetes_namespace.longhorn_system
  ]
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.10.0"
  namespace  = kubernetes_namespace.longhorn_system.metadata[0].name
  timeout    = 600

  values = [
    yamlencode({
      defaultSettings = {
        systemManagedComponentsNodeSelector = "!node-role.kubernetes.io/master"
      }
      defaultBackupStore = {
        backupTarget                 = "s3://longhorn@us-east-1/"
        backupTargetCredentialSecret = "longhorn-secrets"
      }
      persistence = {
        defaultClassReplicaCount = 2
      }
      longhornUI = {
        replicas = 1
      }
      # service = {
      #   ui = {
      #     enabled = true
      #     type    = "LoadBalancer"
      #   }
      # }
    })
  ]

  depends_on = [
    kubernetes_manifest.longhorn_external_secret
  ]
}

resource "kubectl_manifest" "longhorn_daily_backup" {
  yaml_body = <<YAML
apiVersion: longhorn.io/v1beta2
kind: RecurringJob
metadata:
  name: daily-backup
  namespace: longhorn-system
spec:
  concurrency: 1
  cron: "0 1 * * *"
  groups:
    - default
  retain: 3
  task: backup-force-create
YAML

  depends_on = [
    helm_release.longhorn
  ]
}
