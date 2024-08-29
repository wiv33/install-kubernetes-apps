variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
}

variable "oidc_secret" {
  description = "OIDC secret"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL"
  type        = string
}

variable "domain" {
  description = "Domain"
  type        = string
}

variable "gateway_name" {
  description = "Gateway namespace and name"
  type        = string
}