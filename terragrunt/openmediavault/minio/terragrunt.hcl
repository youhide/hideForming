include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/terraform/minio"
}

inputs = {
  enabled = true

  minio_parameters = [
    {
      bucket_name   = "longhorn"
      bucket_acl    = "private"
      force_destroy = false
    }
  ]
}
