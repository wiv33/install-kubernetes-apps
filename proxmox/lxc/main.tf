locals {
  bridge = "vmbr0"
  ip_prefix = "192.168.2"
  gw_prefix = "${local.ip_prefix}.1"
}
resource "proxmox_lxc" "k-master" {
  count        = 3
  target_node  = var.proxmox_host
  vmid         = 7770 + count.index
  ostemplate   = "local:vztmpl/ubuntu-23.10-standard_23.10-1_amd64.tar.zst"
  pool         = "k8s"
  unprivileged = true
  tags         = "terraform;k8s-master;23.10;ubuntu"
  cores        = 4
  hostname     = "master${count.index}"
  password     = var.os_password
  memory       = 16384
  onboot       = true
  start        = true

  ssh_public_keys = var.os_ssh_key_pub
  connection {
    user = "shin"
    password = var.os_password
  }

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "50G"
  }

  network {
    name     = "eth0"
    bridge   = local.bridge
    ip       = "${local.ip_prefix}.13${count.index}/24"
    gw       = local.gw_prefix
    ip6      = "dhcp"
    firewall = false
  }
}

resource "proxmox_lxc" "k-worker" {
  count        = 8
  target_node  = var.proxmox_host
  vmid         = 7780 + count.index
  ostemplate   = "local:vztmpl/ubuntu-23.10-standard_23.10-1_amd64.tar.zst"
  pool         = "k8s"
  unprivileged = true
  tags         = "terraform;k8s-worker;23.10;ubuntu"
  cores        = 4
  hostname     = "worker${count.index}"
  password     = var.os_password
  memory       = 16384 * 2
  onboot       = true
  start        = true

  ssh_public_keys = var.os_ssh_key_pub
  connection {
    user = "shin"
    password = var.os_password
  }

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "50G"
  }

  network {
    name     = "eth0"
    bridge   = local.bridge
    ip       = "${local.ip_prefix}.14${count.index}/24"
    gw       = local.gw_prefix
    ip6      = "dhcp"
    firewall = false
  }
}