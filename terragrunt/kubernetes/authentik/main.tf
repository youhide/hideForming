resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }
}

resource "kubernetes_secret" "authentik_secrets" {
  metadata {
    name      = "authentik-secrets"
    namespace = kubernetes_namespace.authentik.metadata[0].name
  }

  # data = {
  #   "authentik-secret-key" = ""
  #   "postgresql-password"  = ""
  #   "smtp-password"        = ""
  # }

  type = "Opaque"
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
    kubernetes_secret.authentik_secrets
  ]
}
