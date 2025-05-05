variable "enabled" {
  description = "Enable or disable the module"
  type        = bool
  default     = true
}

variable "minio_parameters" {
  description = "MinIO parameters"
  type = list(object({
    bucket_name   = string
    bucket_acl    = string
    force_destroy = bool
  }))
}
