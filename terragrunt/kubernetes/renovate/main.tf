# resource "kubernetes_namespace" "renovate" {
#   metadata {
#     name = "renovate"
#   }
# }

# resource "kubernetes_secret" "renovate_secrets" {
#   metadata {
#     name      = "renovate-env"
#     namespace = kubernetes_namespace.renovate.metadata[0].name
#   }

#   data = {
#     "RENOVATE_PLATFORM"   = "github"
#     "RENOVATE_ENDPOINT"   = "https://api.github.com/"
#     "RENOVATE_GIT_AUTHOR" = "YouHide Renovate Bot <youhide_renovate@none.com>"
#     "RENOVATE_APP_NAME"   = "YouHide Renovate"
#     "RENOVATE_TOKEN"      = ""
#     "RENOVATE_APP_ID"     = "1241886"
#     "RENOVATE_APP_KEY"    = ""
#   }

#   type = "Opaque"
# }

# resource "helm_release" "renovate" {
#   name       = "renovate"
#   repository = "https://renovatebot.github.io/helm-charts"
#   chart      = "renovate"
#   version    = "40.3.4"
#   namespace  = kubernetes_namespace.renovate.metadata[0].name
#   timeout    = 600

#   values = [<<EOF
# renovate:
#   config: |
#     {
#       "dryRun": true,
#       "repositories": ["youhide/hideForming"]
#     }    
# envFrom:
#   - secretRef:
#       name: renovate-env
#   EOF    
#   ]

#   depends_on = [
#     kubernetes_namespace.renovate,
#     kubernetes_secret.renovate_secrets
#   ]

# }
