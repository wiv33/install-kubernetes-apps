locals {
  repo_url = "https://helm.elastic.co"
  version  = "7.17.3"
}

data "kubernetes_namespace" "elastic" {
  metadata {
    name = "elastic"
  }
}

resource "kubernetes_secret" "elastic-secret" {
  metadata {
    name      = "elastic-credentials"
    namespace = data.kubernetes_namespace.elastic.metadata.0.name
  }
  data = {
    password = base64encode(var.elastic_password)
    username = base64encode("elastic")
  }
}

resource "kubernetes_secret" "certificate" {
  metadata {
    name      = "elastic-certificates"
    namespace = data.kubernetes_namespace.elastic.metadata.0.name
  }
  data = {
    "elastic-certificates.p12" = filebase64("elastic-certificates.p12")
  }
}

resource "helm_release" "elasticsearch" {
  depends_on = [kubernetes_secret.elastic-secret]

  repository = local.repo_url
  chart      = "elasticsearch"
  name       = "elasticsearch"
  version    = local.version
  namespace  = data.kubernetes_namespace.elastic.metadata.0.name

  set {
    name  = "protocol"
    value = "http"
  }

  /*
  tolerations:
  - key: type
    operator: Equal
    value: stateful
    effect: NoSchedule
   */
  set {
    name  = "tolerations[0].key"
    value = "type"
  }
  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }
  set {
    name  = "tolerations[0].value"
    value = "stateful"
  }
  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[1].key"
    value = "type"
  }
  set {
    name  = "tolerations[1].operator"
    value = "Equal"
  }
  set {
    name  = "tolerations[1].value"
    value = "backbone"
  }
  set {
    name  = "tolerations[1].effect"
    value = "NoSchedule"
  }


  /*
  extraEnvs:
  - name: ELASTIC_PASSWORD
    valueFrom:
      secretKeyRef:
        name: elastic-credentials
        key: password
   */
  set {
    name  = "extraEnvs[0].name"
    value = "ELASTIC_PASSWORD"
  }
  set {
    name  = "extraEnvs[0].valueFrom.secretKeyRef.name"
    value = kubernetes_secret.elastic-secret.metadata.0.name
  }
  set {
    name  = "extraEnvs[0].valueFrom.secretKeyRef.key"
    value = "password"
  }

  #   set {
  #     name  = "esConfig.elasticsearch\\.yml"
  #     value = "thread_pool.write.queue_size: 333\ncluster.max_shards_per_node: 999\nxpack.security.enabled: true\nxpack.security.transport.ssl.enabled: true\nxpack.security.transport.ssl.verification_mode: certificate\nxpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12\nxpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12\nxpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12\nxpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12\nxpack.security.http.ssl.enabled: true\n"
  #   }
  #
  #   set {
  #     name  = "secretMounts[0].name"
  #     value = "elastic-certificates"
  #   }
  #   set {
  #     name  = "secretMounts[0].secretName"
  #     value = "elastic-certificates"
  #   }
  #   set {
  #     name  = "secretMounts[0].path"
  #     value = "/usr/share/elasticsearch/config/certs"
  #   }

}

resource "helm_release" "kibana" {
  depends_on = [helm_release.elasticsearch]

  repository = local.repo_url
  chart      = "kibana"
  name       = "kibana"
  version    = local.version
  namespace  = data.kubernetes_namespace.elastic.metadata.0.name
  values = [file("../../elastic/kibana/values.yaml")]

  set {
    name  = "elasticsearchCredentialSecret"
    value = "elastic-credentials"
  }

  set {
    name  = "tolerations[0].key"
    value = "type"
  }
  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }
  set {
    name  = "tolerations[0].value"
    value = "web"
  }
  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

}

data "kubernetes_service" "elastic-svc" {
  depends_on = [helm_release.elasticsearch]
  metadata {
    name      = "elasticsearch-master"
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


data "kubernetes_service" "kibana-svc" {
  depends_on = [helm_release.kibana]
  metadata {
    name      = "kibana-kibana"
    namespace = data.kubernetes_namespace.elastic.metadata.0.name
  }
}

resource "kubernetes_manifest" "kibana-vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "kibana-vs"
      namespace = data.kubernetes_namespace.elastic.metadata.0.name
    }

    spec = {
      hosts = ["kibana.${var.domain}"]
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
                host = "${data.kubernetes_service.kibana-svc.metadata.0.name}.${data.kubernetes_namespace.elastic.metadata.0.name}.svc.cluster.local"
                port = {
                  number = data.kubernetes_service.kibana-svc.spec[0].port[0].port
                }
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "kibana-dr" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "DestinationRule"
    metadata = {
      name      = "kibana-dr"
      namespace = data.kubernetes_namespace.elastic.metadata.0.name
    }

    spec = {
      host = "${data.kubernetes_service.kibana-svc.metadata.0.name}.${data.kubernetes_namespace.elastic.metadata.0.name}.svc.cluster.local"
      trafficPolicy = {
        loadBalancer = {
          #           simple = "ROUND_ROBIN"
          simple = "LEAST_CONN"
        }
      }
    }
  }
}