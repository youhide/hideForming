resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }
}

resource "kubernetes_manifest" "authentik_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "authentik-vault-secrets"
      namespace = kubernetes_namespace.authentik.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "vault-backend"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "authentik-secrets"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "postgresql-password"
          remoteRef = {
            key      = "TKA-Authentik-postgresql-password"
            property = "password"
          }
        },
        {
          secretKey = "authentik-secret-key"
          remoteRef = {
            key      = "TKA-Authentik-secret-key"
            property = "password"
          }
        },
        {
          secretKey = "smtp-password"
          remoteRef = {
            key      = "TKA-Authentik-smtp-password"
            property = "password"
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_namespace.authentik
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
  ingress:
    # Specify kubernetes ingress controller class name
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
redis:
  enabled: true
EOF
  ]

  depends_on = [
    kubernetes_namespace.authentik,
    kubernetes_manifest.authentik_external_secret
  ]
}
