variable "proxmox_api_url" {
  description = "The URL of the Proxmox API"
}

variable "proxmox_api_token_id" {
  description = "The API token ID for the Proxmox API"
}

variable "proxmox_api_token_secret" {
  description = "The API token secret for the Proxmox API"
}
variable "proxmox_host" {
  description = "The Proxmox host to use"
}

variable "os_user" {
  description = "The OS user to use for SSH access to the instance"
}

variable "os_password" {
  description = "The OS password to use for SSH access to the instance"
}

variable "os_ssh_key" {
  description = "The SSH key to use for SSH access to the instance"
}

variable "os_ssh_key_pub" {
  description = "The SSH public key to use for SSH access to the instance"
}
