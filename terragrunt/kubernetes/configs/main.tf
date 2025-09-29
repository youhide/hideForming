resource "kubernetes_node_taint" "master_taint" {
  metadata {
    name = "k3s-main"
  }

  taint {
    key    = "node-role.kubernetes.io/master"
    value  = "true"
    effect = "NoSchedule"
  }

  force = true
}
