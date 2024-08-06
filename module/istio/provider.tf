terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.19.1"
    }
  }

  required_version = ">= 0.13"
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

provider "restapi" {
  uri                  = var.iptime_host
  write_returns_object = true
  debug                = true

  headers = {
    "Content-Type" = "application/x-www-form-urlencoded"
  }

  create_method  = "POST"
  update_method  = "POST"
  destroy_method = "PUT"
  username = var.iptime_username
  password = var.iptime_password
}