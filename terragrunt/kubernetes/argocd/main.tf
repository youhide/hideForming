locals {
  # Configuration variables
  argocd_domain       = "argocd.youhide.com.br"
  auth_domain         = "auth.tkasolutions.com.br"
  admin_groups        = ["authentik Admins"]
  chart_version       = "5.51.6"
  authentik_client_id = "argocd"
  default_policy      = "role:readonly"

  # Replicas configuration
  replicas = {
    controller      = 1
    repo_server     = 1
    application_set = 1
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = "argocd"
    }
  }
}

# Generate random passwords automatically
resource "random_password" "argocd_admin_password" {
  length  = 32
  special = true
}

resource "random_password" "argocd_server_secret_key" {
  length  = 64
  special = false # Server key should be alphanumeric only
}

# Store generated secrets in Vault automatically
resource "vault_generic_secret" "argocd_admin_password" {
  path = "secret/ArgoCD-admin-password"
  data_json = jsonencode({
    password = random_password.argocd_admin_password.result
  })
}

resource "vault_generic_secret" "argocd_server_secret_key" {
  path = "secret/ArgoCD-server-secret-key"
  data_json = jsonencode({
    password = random_password.argocd_server_secret_key.result
  })
}

resource "kubernetes_manifest" "argocd_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "argocd-vault-secrets"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        name = "vault-backend"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "argocd-secret"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "admin.password"
          remoteRef = {
            key      = "ArgoCD-admin-password"
            property = "password"
          }
        },
        {
          secretKey = "server.secretkey"
          remoteRef = {
            key      = "ArgoCD-server-secret-key"
            property = "password"
          }
        },
        {
          secretKey = "oidc-client-secret"
          remoteRef = {
            key      = "ArgoCD-oidc-client-secret"
            property = "password"
          }
        }
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = local.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  timeout    = 600

  values = [
    yamlencode({
      global = {
        domain = local.argocd_domain
      }
      configs = {
        secret = {
          createSecret                   = false
          argocdServerAdminPassword      = null
          argocdServerAdminPasswordMtime = null
        }
        cm = {
          url                      = "https://${local.argocd_domain}"
          "accounts.admin.enabled" = "false"
          "oidc.config" = yamlencode({
            name            = "Authentik"
            issuer          = "https://${local.auth_domain}/application/o/${local.authentik_client_id}/"
            clientId        = local.authentik_client_id
            clientSecret    = "$oidc-client-secret"
            requestedScopes = ["openid", "profile", "email", "groups"]
            requestedIDTokenClaims = {
              groups = {
                essential = true
              }
            }
          })
        }
        rbac = {
          "policy.default" = local.default_policy
          "policy.csv"     = join("\n", [for group in local.admin_groups : "g, ${group}, role:admin"])
        }        
      }
      server = {
        config = {
          url = "https://${local.argocd_domain}"
        }
        ingress = {
          enabled = false
        }
        service = {
          type = "LoadBalancer"
          annotations = {
            "metallb.universe.tf/loadBalancerIPs" = "192.168.220.15"
          }
        }
        extraEnvVarsFrom = [
          {
            secretRef = {
              name = "argocd-secret"
            }
          }
        ]
      }
      controller = {
        replicas = local.replicas.controller
      }
      repoServer = {
        replicas = local.replicas.repo_server
      }
      applicationSet = {
        enabled  = true
        replicas = local.replicas.application_set
      }
      notifications = {
        enabled = false
      }
      redis = {
        enabled = true
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_manifest.argocd_external_secret
  ]
}
