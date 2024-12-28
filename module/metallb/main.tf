locals {

}

resource "kubernetes_namespace" "metallb-system" {
  metadata {
    name = "metallb-system"
  }
}

# MetalLB 설치
# MetalLB Helm 설치
resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = kubernetes_namespace.metallb-system.metadata[0].name
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.10" # 원하는 MetalLB Chart 버전

  set {
    name  = "controller.tolerations[0].key"
    value = "type"
  }
  set {
    name  = "controller.tolerations[0].value"
    value = "web"
  }
  set {
    name  = "controller.tolerations[0].operator"
    value = "Equal"
  }
  set {
    name  = "controller.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "speaker.tolerations[0].key"
    value = "type"
  }
  set {
    name  = "speaker.tolerations[0].value"
    value = "web"
  }
  set {
    name  = "speaker.tolerations[0].operator"
    value = "Equal"
  }
  set {
    name  = "speaker.tolerations[0].effect"
    value = "NoSchedule"
  }

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
  depends_on = [helm_release.metallb]
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
