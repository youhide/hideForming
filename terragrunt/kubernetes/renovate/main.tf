resource "kubernetes_namespace" "renovate" {
  metadata {
    name = "renovate"
  }
}

resource "kubernetes_manifest" "renovate_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "renovate-vault-secrets"
      namespace = kubernetes_namespace.renovate.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "vault-backend"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "renovate-env"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "RENOVATE_TOKEN"
          remoteRef = {
            key      = "hideOut-GitHub-RenovateApp-token"
            property = "password"
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_namespace.renovate
  ]
}

resource "helm_release" "renovate" {
  name       = "renovate"
  repository = "https://renovatebot.github.io/helm-charts"
  chart      = "renovate"
  version    = "44.9.1"
  namespace  = kubernetes_namespace.renovate.metadata[0].name
  timeout    = 600

  values = [
    yamlencode({
      renovate = {
        config = jsonencode({
          platform     = "github"
          gitAuthor    = "YouHide Renovate Bot <youhide_renovate@none.com>"
          repositories = ["youhide/hideForming"]
        })
      }
      envFrom = [
        {
          secretRef = {
            name = "renovate-env"
          }
        }
      ]
    })
  ]

  depends_on = [
    kubernetes_namespace.renovate,
    kubernetes_manifest.renovate_external_secret
  ]
}
