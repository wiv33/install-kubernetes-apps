data "kubernetes_namespace_v1" "kafka" {
  metadata {
    name = "kafka"
  }
}

resource "helm_release" "kafka" {
  name         = "kafka"
  repository   = "https://charts.bitnami.com/bitnami"
  chart        = "kafka"

  namespace    = data.kubernetes_namespace_v1.kafka.metadata.0.name
  version      = "30.1.8"
  values = [
    file("${path.module}/my-values.yaml")
  ]

  set {
    name  = "controller.tolerations[0].key"
    value = "type"
  }
  set {
    name  = "controller.tolerations[0].value"
    value = "backbone"
  }
  set {
    name  = "controller.tolerations[0].effect"
    value = "NoSchedule"
  }
  set {
    name  = "controller.tolerations[0].operator"
    value = "Equal"
  }

  set {
    name  = "listeners.client.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "listeners.external.protocol"
    value = "PLAINTEXT"
  }
  set {
    name  = "listeners.controller.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "controller.persistence.size"
    value = "50Gi"
  }

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

}

resource "kubernetes_manifest" "kafka-vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "kafka-vs"
      namespace = data.kubernetes_namespace_v1.kafka.metadata.0.name
    }
    spec = {
      hosts = ["*"]
      gateways = ["istio-ingress/default-gateway"]
      tcp = [
        {
          match = [
            {
              port : 9092
            },
            {
              port : 9094
            },
            {
              port : 9095
            }
          ]
          route = [
            {
              destination = {
                host : "kafka.kafka.svc.cluster.local"
                port : {
                  number : 9092
                }
              }
            }
          ]
        }
      ]
    }
  }
}

resource "helm_release" "kafka-ui" {
  depends_on = [helm_release.kafka]
  repository   = "https://provectus.github.io/kafka-ui-charts"
  chart        = "kafka-ui"
  name         = "kafka-ui"
  namespace    = data.kubernetes_namespace_v1.kafka.metadata.0.name
  version      = "0.7.6"

  set {
    name  = "yamlApplicationConfig.kafka.clusters[0].name"
    value = var.kafka_ui_cluster_name
  }

  set {
    name  = "yamlApplicationConfig.kafka.clusters[0].bootstrapServers"
    value = "kafka.kafka.svc.cluster.local:9092"
  }

  set {
    name  = "yamlApplicationConfig.spring.security.user.name"
    value = var.kafka_ui_username
  }
  set {
    name  = "yamlApplicationConfig.spring.security.user.password"
    value = var.kafka_ui_password
  }
  set {
    name  = "yamlApplicationConfig.auth.type"
    value = "login_form"
  }
}

resource "kubernetes_manifest" "kafka-ui-vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "kafka-ui"
      namespace = data.kubernetes_namespace_v1.kafka.metadata.0.name
    }
    spec = {
      hosts = var.kafka_ui_hosts # ["kafka-ui.my-domain.com"]
      gateways = ["istio-ingress/default-gateway"]
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
                host = "kafka-ui.kafka.svc.cluster.local"
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