terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }

  required_version = ">= 0.13"
}

provider "kubernetes" {
  config_path = var.kube_config_path
}
