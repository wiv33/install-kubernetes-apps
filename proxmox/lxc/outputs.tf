output "master-ips" {
  value = proxmox_lxc.k-master.*.network[*][0].ip
}

output "worker-ips" {
    value = proxmox_lxc.k-worker.*.network[*][0].ip
}