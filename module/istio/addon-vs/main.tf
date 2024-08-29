locals {
  ns = "istio-system"
}

resource "kubernetes_manifest" "grafana_vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "grafana-vs"
      namespace = local.ns
    }
    spec = {
      hosts = ["grafana.${var.domain}"]
      gateways = [var.gateway_name]
      http = [
        {
          route = [
            {
              destination = {
                host = "grafana.${local.ns}.svc.cluster.local"
                port = {
                  number = 3000
                }
              }
            }
          ]
        }
      ]
    }
  }
}

// jaeger vs
resource "kubernetes_manifest" "jaeger-vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "jaeger-vs"
      namespace = local.ns
    }
    spec = {
      hosts = ["jaeger.${var.domain}"]
      gateways = [var.gateway_name]
      http = [
        {
          route = [
            {
              destination = {
                host = "tracing.${local.ns}.svc.cluster.local"
                port = {
                  number = 80
                }
              }
            }
          ]
        }
      ]
    }
  }
}

// jaeger vs
resource "kubernetes_manifest" "jaeger-zipkin-vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "jaeger-zipkin-vs"
      namespace = local.ns
    }
    spec = {
      hosts = ["jaeger-zipkin.${var.domain}"]
      gateways = [var.gateway_name]
      http = [
        {
          route = [
            {
              destination = {
                host = "zipkin.${local.ns}.svc.cluster.local"
                port = {
                  number = 9411
                }
              }
            }
          ]
        }
      ]
    }
  }
}