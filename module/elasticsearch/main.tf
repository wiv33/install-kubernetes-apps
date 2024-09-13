locals {
  repo_url = "https://helm.elastic.co"
  version  = "7.17.3"
}

resource "kubernetes_namespace" "elastic" {
  metadata {
    name = "elastic"
  }
}

resource "kubernetes_secret" "elastic-secret" {
  metadata {
    name      = "elastic-credentials"
    namespace = kubernetes_namespace.elastic.metadata.0.name
  }
  data = {
    password = base64encode(var.elastic_password)
  }
}

resource "helm_release" "elasticsearch" {
  depends_on = [kubernetes_secret.elastic-secret]

  repository = local.repo_url
  chart      = "elasticsearch"
  name       = "elasticsearch"
  version    = local.version
  namespace  = kubernetes_namespace.elastic.metadata.0.name
#   values = [file("../../elastic/elasticsearch/values.yaml")]

  set {
    name  = "protocol"
    value = "http"
  }

  set {
    name  = "service.httpPortName"
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

}

resource "helm_release" "kibana" {
  depends_on = [helm_release.elasticsearch]

  repository = local.repo_url
  chart      = "kibana"
  name       = "kibana"
  version    = local.version
  namespace  = kubernetes_namespace.elastic.metadata.0.name
  values = [file("../../elastic/kibana/values.yaml")]

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

}

data "kubernetes_service" "elastic-svc" {
  depends_on = [helm_release.elasticsearch]
  metadata {
    name      = "elasticsearch-master"
    namespace = kubernetes_namespace.elastic.metadata.0.name
  }
}

resource "kubernetes_manifest" "elastic-vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "elastic-vs"
      namespace = kubernetes_namespace.elastic.metadata.0.name
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
                host = "${data.kubernetes_service.elastic-svc.metadata.0.name}.${kubernetes_namespace.elastic.metadata.0.name}.svc.cluster.local"
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
      namespace = kubernetes_namespace.elastic.metadata.0.name
    }

    spec = {
      host = "${data.kubernetes_service.elastic-svc.metadata.0.name}.${kubernetes_namespace.elastic.metadata.0.name}.svc.cluster.local"
      trafficPolicy = {
        loadBalancer = {
#           simple = "ROUND_ROBIN"
          simple = "LEAST_CONN"
        }
      }
    }
  }
}

