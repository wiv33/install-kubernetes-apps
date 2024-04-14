locals {
  bridge  = "vmbr0"
  storage = "local-lvm"
}
resource "proxmox_vm_qemu" "k8s-master" {
  count       = 3
  #  agent       = 1
  name        = "k8s-master-${count.index}"
  target_node = var.proxmox_host[0]
  vmid        = 300 + count.index
  clone       = var.template_name
  cores       = 2
  sockets     = 1
  memory      = 16384
  #  hotplug     = "disk,network,usb"
  #  bios        = "ovmf"
  os_type     = "ubuntu"
  #  iso         = "local:iso/ubuntu-23.10-live-server-amd64.iso"

  #  boot       = "order=scsi0;ide2;net0"
  #  os_type           = "Linux"
  #  scsihw     = "virtio-scsi-single"
  full_clone = true
  /*
    disks {
      scsi {
        scsi0 {
          disk {
            storage = local.storage
            size    = 50
          }
        }
      }
    }
  */

  tags = "k8s-master"

  network {
    model     = "virtio"
    bridge    = local.bridge
    #    tag       = 300
    firewall  = false
    link_down = false
  }

  ipconfig0  = "ip=192.168.0.20${count.index}/24,gw=192.168.0.1"
  ciuser     = var.username
  cipassword = var.password
  #  nameserver = "8.8.8.8,8.8.4.4"

  #  ssh_private_key = <<EOF
  #${var.ssh_key}
  #EOF
}
/*

resource "proxmox_vm_qemu" "k8s-worker" {
  target_node = var.proxmox_host[0]
  count       = 7
  agent       = 1
  name        = "k8s-worker-${count.index}"
  vmid        = 400 + count.index
  clone       = var.template_name
  #  os_type     = "l26"
  #  cpu         = "kvm64"
  cores       = 2
  sockets     = 1
  memory      = 16384 * 2
  hotplug     = "Network,Disk,Usb"
  boot        = "virtio0,ide2,net0"
  os_type     = "Linux"
  os_network  = 1
  #  scsihw      = "virtio-scsi-pci"
  #  bootdisk    = "scsi0"
  #  kvm         = true
  #  full_clone = true

  disks {
    scsi {
      scsi0 {
        disk {
          storage = local.storage
        }
      }
    }
  }

  */
/*
    network {
      model     = "virtio"
      bridge    = local.bridge
      tag       = 400
      firewall  = false
      #    link_down = false
      macaddr   = "52:54:00:00:44:0${count.index}"
  #    link_down = true
    }

    ipconfig0  = "ip=192.168.0.24${count.index}/24,gw=192.168.0.1"
    ciuser     = var.username
    cipassword = var.password
  *//*

  #  nameserver = "8.8.8.8,8.8.4.4"
  #  ssh_private_key = <<EOF
  #${var.ssh_key}
  #EOF
}
*/
