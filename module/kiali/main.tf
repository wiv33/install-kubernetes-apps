// repository = https://kiali.org/helm-charts

locals {
  kiali_repo_url = "https://kiali.org/helm-charts"
  kiali_version  = "1.89.0"
  ns             = "istio-system"
  target_ns      = "phoneshin"
}

resource "kubernetes_namespace" "kiali" {
  metadata {
    name = "kiali-operator"
  }
}

resource "helm_release" "kiali_operator" {
  repository = local.kiali_repo_url
  version    = local.kiali_version
  chart      = "kiali-operator"
  name       = "kiali-operator"
  namespace  = kubernetes_namespace.kiali.metadata[0].name

  set {
    name  = "cr.create"
    value = "true"
  }

  set {
    name  = "cr.namespace"
    value = local.ns
  }

  set {
    name  = "spec.auth.strategy"
    value = "openid"
  }

  set {
    name  = "spec.auth.openid.client_id"
    value = "kiali"
  }

  set {
    name  = "spec.auth.openid.issuer_uri"
    value = var.oidc_issuer_url
  }

  set {
    name  = "spec.server.gzip_enabled"
    value = "true"
  }

  set {
    name  = "spec.server.cors_allow_all"
    value = "true"
  }

}

resource "kubernetes_manifest" "phoneshin_kiali" {
  depends_on = [helm_release.kiali_operator]
  manifest = {
    apiVersion = "kiali.io/v1alpha1"
    kind       = "Kiali"
    metadata = {
      name      = "kiali-phoneshin"
      namespace = local.ns
    }
    spec = {
#       auth = {
#         strategy = "openid"
#         openid = {
#           client_id  = "kiali"
#           issuer_uri = var.oidc_issuer_url
#         }
      auth = {
        strategy = "anonymous"
      }
      deployment = {
        accessible_namespaces = [local.target_ns]
        view_only_mode = false
      }
      server = {
        web_root = "/${local.target_ns}"
      }
    }
  }
}

resource "kubernetes_manifest" "kiali_vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "kiali-vs"
      namespace = local.ns
    }
    spec = {
      hosts = ["kiali.${var.domain}"]
      gateways = [var.gateway_name]
      http = [
        {
          route = [
            {
              destination = {
                host = "kiali.${local.ns}.svc.cluster.local"
                port = {
                  number = 20001
                }
              }
            }
          ]
        }
      ]
    }
  }
}