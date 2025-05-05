include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/terraform/kubernetes-vault"
}

inputs = {
  vault_server      = "http://vault.localdomain:8200"
  create_namespace  = true
  namespace         = "vault"
  vault_chart_version = "0.27.0"
}
