locals {

}

resource "kubernetes_namespace" "metallb-system" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "bitnami-metallb" {
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"
  name       = "metallb"
  namespace  = "metallb-system"
  version    = "6.3.9"
  wait       = true
}

/*
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  # A name for the address pool. Services can request allocation
  # from a specific address pool using this name.
  name: first-pool
  namespace: metallb-system
spec:
  # A list of IP address ranges over which MetalLB has
  # authority. You can list multiple ranges in a single pool, they
  # will all share the same settings. Each range can be either a
  # CIDR prefix, or an explicit start-end range of IPs.
  addresses:
    - 10.5.0.0/16
    - 10.6.0.0/16
    - 10.10.0.0/16
    - fc00:f853:0ccd:e799::/124
 */
resource "kubernetes_manifest" "ip-pool" {
  depends_on = [helm_release.bitnami-metallb]
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "first-pool"
      namespace = "metallb-system"
    }
    spec = {
      addresses = [
        "10.5.0.0/16",
        "10.6.0.0/16",
        "10.7.0.0/16"
      ]
    }
  }
}