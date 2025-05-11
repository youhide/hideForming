resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.14.9"
  namespace  = kubernetes_namespace.metallb.metadata[0].name
  timeout    = 600

  values = [
    yamlencode({
      controller = {
        logLevel = "info"
      }
      speaker = {
        logLevel = "info"
      }
      crds = {
        enabled = true
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.metallb
  ]
}

resource "kubectl_manifest" "metallb_ipaddresspool" {
  yaml_body = <<-EOF
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: default-pool
      namespace: ${kubernetes_namespace.metallb.metadata[0].name}
    spec:
      addresses:
        - "192.168.220.5-192.168.220.60"
  EOF

  depends_on = [
    helm_release.metallb
  ]
}

# resource "kubectl_manifest" "metallb_l2advertisement" {
#   yaml_body = <<-EOF
#     apiVersion: metallb.io/v1beta1
#     kind: L2Advertisement
#     metadata:
#       name: default-advertisement
#       namespace: ${kubernetes_namespace.metallb.metadata[0].name}
#     spec:
#       ipAddressPools:
#         - default-pool
#   EOF

#   depends_on = [
#     kubectl_manifest.metallb_ipaddresspool
#   ]
# }

resource "kubectl_manifest" "metallb_bgp_advertisement" {
  yaml_body = <<-EOF
    apiVersion: metallb.io/v1beta1
    kind: BGPAdvertisement
    metadata:
      name: bgp-advertisement
      namespace: ${kubernetes_namespace.metallb.metadata[0].name}
    spec:
      ipAddressPools:
        - default-pool
  EOF

  depends_on = [
    kubectl_manifest.metallb_ipaddresspool
  ]
}

resource "kubectl_manifest" "metallb_bgp_peer" {
  yaml_body = <<-EOF
    apiVersion: metallb.io/v1beta2
    kind: BGPPeer
    metadata:
      name: udm-pro
      namespace: ${kubernetes_namespace.metallb.metadata[0].name}
    spec:
      myASN: 65001
      peerASN: 65000
      peerAddress: 192.168.29.1  # IP do UDM Pro
  EOF

  depends_on = [
    helm_release.metallb
  ]
}
