terraform {
  required_version = ">= 0.13"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}
provider "proxmox" {
  pm_api_url          = "https://psawesome.xyz:48006/api2/json"
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  #  pm_user         = "root@pam"
  #  pm_password     = "Afsdqwer3#"
  pm_tls_insecure     = true
  pm_parallel         = 11
  # debug log
  pm_log_enable       = true
  pm_log_file         = "terraform-plugin-proxmox.log"
  pm_debug            = true
  pm_log_levels       = {
    _default    = "debug"
  }
}

