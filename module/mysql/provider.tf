terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.config_path
  }
}

provider "kubernetes" {
  config_path = var.config_path
}
