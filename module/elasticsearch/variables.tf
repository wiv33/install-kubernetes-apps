variable "kube_config_path" {
  description = "Path to the kubeconfig file"
}

variable "elastic_password" {
  description = "Password for the elastic user"
}

variable "istio_gateway" {
  description = "Gateway for the istio ingress"
}

variable "domain" {
  description = "Domain for the application"
}

variable "credential_name" {
  description = "Name of the secret containing the elastic credentials"
}