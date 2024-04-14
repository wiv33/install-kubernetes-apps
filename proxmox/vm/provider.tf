provider "proxmox" {
  pm_api_url      = "https://psawesome.xyz:48006/api2/json"
  #  pm_api_token_id = "tfuser@pve!terraform"
  #  pm_api_token_secret = var.PROXMOX_API_SECRET
  pm_user         = "root@pam"
  pm_password     = "Afsdqwer3#"
  pm_tls_insecure = true
  pm_parallel     = 11
  # debug log
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_debug        = true
  pm_log_levels   = {
    _default    = "debug"
    _capturelog = ""
  }
}

