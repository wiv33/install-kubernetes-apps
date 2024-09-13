locals {
  repo_url = "https://helm.elastic.co"
  version  = "7.16.3"
}

data "kubernetes_namespace" "elastic" {
  metadata {
    name = "elastic"
  }
}
#
# resource "helm_release" "kibana" {
#   depends_on = [helm_release.elasticsearch]
#
#   repository = local.repo_url
#   chart      = "kibana"
#   name       = "kibana"
#   version    = local.version
#   namespace  = data.kubernetes_namespace.elastic.metadata.0.name
#   values = [file("../../elastic/kibana/values.yaml")]
#
#   set {
#     name  = "elasticsearchCredentialSecret"
#     value = "elastic-credentials"
#   }
#
#   set {
#     name  = "tolerations[0].key"
#     value = "type"
#   }
#   set {
#     name  = "tolerations[0].operator"
#     value = "Equal"
#   }
#   set {
#     name  = "tolerations[0].value"
#     value = "web"
#   }
#   set {
#     name  = "tolerations[0].effect"
#     value = "NoSchedule"
#   }
#
# }
#

data "kubernetes_service" "elastic-svc" {
  metadata {
    name      = "security-master"
    namespace = data.kubernetes_namespace.elastic.metadata.0.name
  }
}

resource "kubernetes_manifest" "elastic-vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "elastic-vs"
      namespace = data.kubernetes_namespace.elastic.metadata.0.name
    }

    spec = {
      hosts = ["es.${var.domain}"]
      gateways = [var.istio_gateway]
      http = [
        {
          match = [
            {
              uri = {
                prefix = "/"
              }
            }
          ]
          route = [
            {
              destination = {
                host = "${data.kubernetes_service.elastic-svc.metadata.0.name}.${data.kubernetes_namespace.elastic.metadata.0.name}.svc.cluster.local"
                port = {
                  number = data.kubernetes_service.elastic-svc.spec[0].port[0].port
                }
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "elastic-dr" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "DestinationRule"
    metadata = {
      name      = "elastic-dr"
      namespace = data.kubernetes_namespace.elastic.metadata.0.name
    }

    spec = {
      host = "${data.kubernetes_service.elastic-svc.metadata.0.name}.${data.kubernetes_namespace.elastic.metadata.0.name}.svc.cluster.local"
      trafficPolicy = {
        loadBalancer = {
          #           simple = "ROUND_ROBIN"
          simple = "LEAST_CONN"
        }
      }
    }
  }
}


# data "kubernetes_service" "kibana-svc" {
#   depends_on = [helm_release.kibana]
#   metadata {
#     name      = "kibana-kibana"
#     namespace = data.kubernetes_namespace.elastic.metadata.0.name
#   }
# }
#
# resource "kubernetes_manifest" "kibana-vs" {
#   manifest = {
#     apiVersion = "networking.istio.io/v1beta1"
#     kind       = "VirtualService"
#     metadata = {
#       name      = "kibana-vs"
#       namespace = data.kubernetes_namespace.elastic.metadata.0.name
#     }
#
#     spec = {
#       hosts = ["kibana.${var.domain}"]
#       gateways = [var.istio_gateway]
#       http = [
#         {
#           match = [
#             {
#               uri = {
#                 prefix = "/"
#               }
#             }
#           ]
#           route = [
#             {
#               destination = {
#                 host = "${data.kubernetes_service.kibana-svc.metadata.0.name}.${data.kubernetes_namespace.elastic.metadata.0.name}.svc.cluster.local"
#                 port = {
#                   number = data.kubernetes_service.kibana-svc.spec[0].port[0].port
#                 }
#               }
#             }
#           ]
#         }
#       ]
#     }
#   }
# }
#
# resource "kubernetes_manifest" "kibana-dr" {
#   manifest = {
#     apiVersion = "networking.istio.io/v1alpha3"
#     kind       = "DestinationRule"
#     metadata = {
#       name      = "kibana-dr"
#       namespace = data.kubernetes_namespace.elastic.metadata.0.name
#     }
#
#     spec = {
#       host = "${data.kubernetes_service.kibana-svc.metadata.0.name}.${data.kubernetes_namespace.elastic.metadata.0.name}.svc.cluster.local"
#       trafficPolicy = {
#         loadBalancer = {
#           #           simple = "ROUND_ROBIN"
#           simple = "LEAST_CONN"
#         }
#       }
#     }
#   }
# }