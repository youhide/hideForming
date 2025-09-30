locals {
  # Configuration for ArgoCD OIDC
  authentik_client_id = "argocd"
}

# Data sources for existing Authentik flows - first try to discover what exists
data "authentik_flow" "authorization_flow" {
  slug = "default-authentication-flow"
}

data "authentik_flow" "invalidation_flow" {
  slug = "default-invalidation-flow"
}

data "authentik_property_mapping_provider_scope" "oauth2" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}

# Data source for finding an RS256 keypair
data "authentik_certificate_key_pair" "rs256_keypair" {
  name = "authentik Self-signed Certificate"
}

# Create OAuth2 Provider for ArgoCD
resource "authentik_provider_oauth2" "argocd" {
  name      = "ArgoCD"
  client_id = local.authentik_client_id

  authorization_flow = data.authentik_flow.authorization_flow.id
  invalidation_flow  = data.authentik_flow.invalidation_flow.id

  property_mappings = data.authentik_property_mapping_provider_scope.oauth2.ids

  client_type = "confidential"

  access_code_validity   = "minutes=1"
  access_token_validity  = "minutes=5"
  refresh_token_validity = "days=30"

  include_claims_in_id_token = true
  issuer_mode                = "per_provider"

  # Use the found keypair for RS256 signing
  signing_key = data.authentik_certificate_key_pair.rs256_keypair.id
}

# Create Authentik Application
resource "authentik_application" "argocd" {
  name              = "ArgoCD"
  slug              = "argocd"
  protocol_provider = authentik_provider_oauth2.argocd.id

  meta_description = "GitOps continuous delivery tool for Kubernetes"
  meta_publisher   = "Argo Project"

  policy_engine_mode = "any"
}

# Store the client secret in Vault automatically
resource "vault_generic_secret" "argocd_oidc_client_secret" {
  path = "secret/ArgoCD-oidc-client-secret"

  data_json = jsonencode({
    password = authentik_provider_oauth2.argocd.client_secret
  })
}
