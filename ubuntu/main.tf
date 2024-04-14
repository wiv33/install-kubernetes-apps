terraform {

}



resource "null_resource" "master" {
  count = 1

#  provisioner "local-exec" {
#    command = "ssh-copy-id "
#  }

  provisioner "remote-exec" {
    connection {
      host     = var.host[count.index]
      user     = var.host_user
      password = var.host_pw
      type = "ssh"
    }

    inline = [
      "sudo swapoff -a",
      "sudo whoami",
#      "echo ${var.host_pw} | sudo -S -k echo '${file("./scripts/hosts.txt")}' >> /etc/hosts",
#      "sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'",
#      "sudo apt install vim python3.10 python3-pip -y",
#      "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1",
    ]
  }


}