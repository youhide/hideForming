variable "vault_addr" {
  description = "The address of the Vault server"
  type        = string
  default     = "http://vault.localdomain:8200"
}

variable "kubernetes_host" {
  description = "The address of the Kubernetes API server"
  type        = string
  default     = "https://k3s-main.localdomain:6443"
}
