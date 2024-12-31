resource "kubernetes_namespace" "openebs" {
  metadata {
    name = "openebs"
  }
}

resource "helm_release" "openebs" {
  repository       = "https://openebs.github.io/openebs"
  chart            = "openebs"
  name             = "openebs"
  namespace        = kubernetes_namespace.openebs.metadata[0].name
  create_namespace = true
  version          = "4.1.0"
  reuse_values     = true
  values = [file("../../openebs/values.yaml")]

  set {
    name  = "mayastor.enabled"
    value = "false"
  }
  set {
    name  = "engines.replicated.mayastor.enabled"
    value = "false"
  }
}

resource "null_resource" "patch_default_sc" {
  depends_on = [helm_release.openebs]
  provisioner "local-exec" {
    command = "kubectl patch storageclass openebs-hostpath -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'"
  }
}