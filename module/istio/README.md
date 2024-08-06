# Automate the binding of the istio-system and iptime port-forward

## Necessary
- `on-premise kubernetes`
- `terraform`
- `iptime`

## Required arguments
```
variable "kube_config_path" {
  description = "Path to the kubeconfig file"
}
variable "iptime_host" {
  description = "Iptime host"
}

variable "iptime_username" {
  description = "Iptime username"
}

variable "iptime_password" {
  description = "Iptime password"
}
```
- kube_config_path
- iptime_host
- iptime_username
- iptime_password

