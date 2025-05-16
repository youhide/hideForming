resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.17.0"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  timeout    = 600

  values = [
    yamlencode({
      installCRDs = true
      serviceAccount = {
        create = true
        name   = "external-secrets"
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.external_secrets
  ]
}

data "kubernetes_config_map" "kube_config" {
  metadata {
    name      = "kube-root-ca.crt"
    namespace = "default"
  }
}

resource "kubernetes_secret" "external_secrets_token" {
  metadata {
    name      = "external-secrets-token"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = "external-secrets"
    }
  }
  type = "kubernetes.io/service-account-token"

  depends_on = [
    helm_release.external_secrets
  ]
}

resource "kubernetes_cluster_role_binding" "vault_token_reviewer" {
  metadata {
    name = "vault-token-reviewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "external-secrets"
    namespace = "external-secrets"
  }
}

resource "kubernetes_role" "external_secrets_role" {
  metadata {
    name      = "external-secrets-role"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["serviceaccounts/token"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role_binding" "external_secrets_rolebinding" {
  metadata {
    name      = "external-secrets-rolebinding"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.external_secrets_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "external-secrets"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "config" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.kubernetes_host
  kubernetes_ca_cert     = data.kubernetes_config_map.kube_config.data["ca.crt"]
  token_reviewer_jwt     = kubernetes_secret.external_secrets_token.data["token"]
  disable_local_ca_jwt   = true
  disable_iss_validation = true
  issuer                 = "https://kubernetes.default.svc.cluster.local"
}

resource "vault_policy" "external_secrets" {
  name   = "external-secrets"
  policy = <<EOT
path "secret/data/*" {
  capabilities = ["read", "list"]
}

path "secret/metadata/*" {
  capabilities = ["read", "list"]
}

path "auth/kubernetes/login" {
  capabilities = ["create", "read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/kubernetes/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.external_secrets.name]
}

# resource "kubernetes_manifest" "vault_secret_store" {
#   manifest = {
#     apiVersion = "external-secrets.io/v1beta1"
#     kind       = "ClusterSecretStore"
#     metadata = {
#       name = "vault-backend"
#     }
#     spec = {
#       provider = {
#         vault = {
#           server  = var.vault_addr
#           path    = "secret"
#           version = "v2"
#           auth = {
#             kubernetes = {
#               mountPath = vault_auth_backend.kubernetes.path
#               role      = vault_kubernetes_auth_backend_role.external_secrets.role_name
#               serviceAccountRef = {
#                 name      = "external-secrets"
#                 namespace = "external-secrets"
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [
#     helm_release.external_secrets,
#     vault_kubernetes_auth_backend_role.external_secrets
#   ]
# }

resource "kubectl_manifest" "vault_secret_store" {
  yaml_body = <<-EOF
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: vault-backend
    spec:
      provider:
        vault:
          server: ${var.vault_addr}
          path: secret
          version: v2
          auth:
            kubernetes:
              mountPath: ${vault_auth_backend.kubernetes.path}
              role: ${vault_kubernetes_auth_backend_role.external_secrets.role_name}
              serviceAccountRef:
                name: external-secrets
                namespace: external-secrets
  EOF

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.external_secrets,
    kubernetes_secret.external_secrets_token,
    vault_auth_backend.kubernetes,
    vault_kubernetes_auth_backend_role.external_secrets
  ]

}
