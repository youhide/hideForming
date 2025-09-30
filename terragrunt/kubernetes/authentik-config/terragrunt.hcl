include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "./"
}

# Dependencies - run after authentik is deployed
dependencies {
  paths = ["../authentik"]
}
