include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/terraform/minio"
}

inputs = {
  enabled = false

  minio_parameters = [
    {
      bucket_name   = "test"
      bucket_acl    = "public"
      force_destroy = true
    }
  ]
}
