variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace for Vault components"
  type        = string
  default     = "vault"
}

variable "vault_server" {
  description = "External Vault server URL"
  type        = string
}

variable "vault_chart_version" {
  description = "Vault Helm chart version"
  type        = string
  default     = "0.27.0"
}
