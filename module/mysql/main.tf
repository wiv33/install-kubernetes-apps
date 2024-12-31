resource "helm_release" "mysql" {
  chart     = "oci://registry-1.docker.io/bitnamicharts/mysql"
  name      = "mysql"
  namespace = "database"

  set {
    name  = "primary.tolerations[0].key"
    value = "type"
  }
  set {
    name  = "primary.tolerations[0].operator"
    value = "Equal"
  }
  set {
    name  = "primary.tolerations[0].value"
    value = "web"
  }


  set {
    name  = "primary.tolerations[1].key"
    value = "type"
  }
  set {
    name  = "primary.tolerations[1].operator"
    value = "Equal"
  }
  set {
    name  = "primary.tolerations[1].value"
    value = "backbone"
  }
  set {
    name  = "primary.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "architecture"
    value = "standalone"
  }

  set {
    name  = "auth.rootPassword"
    value = var.root_password
  }
  set {
    name  = "auth.username"
    value = var.username
  }
  set {
    name  = "auth.password"
    value = var.password
  }
  set {
    name  = "auth.database"
    value = var.database
  }
}

resource "kubernetes_manifest" "mysql-vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "mysql"
      namespace = "database"
    }

    spec = {
      hosts = ["*"]
      gateways = ["istio-ingress/default-gateway"]
      tcp = [
        {
          match = [
            {
              port = 3306
            }
          ]
          route = [
            {
              destination = {
                host = "mysql.database.svc.cluster.local"
                port = {
                  number = 3306
                }
              }
            }
          ]
        }
      ]
    }
  }
}
