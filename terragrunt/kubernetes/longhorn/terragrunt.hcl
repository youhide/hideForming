include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "bucket" {
  config_path = "../../openmediavault/minio"
}

terraform {
  source = "./"
}

inputs = {
  bucket_access_key = dependency.bucket.outputs.service_accounts["longhorn"].access_key
  bucket_secret_key = dependency.bucket.outputs.service_accounts["longhorn"].secret_key
}
