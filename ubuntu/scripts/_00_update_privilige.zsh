#!/usr/bin/env zsh
sudo su root

# after sudo root

swapoff -a
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
echo "192.168.0.14  master1" >> /etc/hosts

apt install python3.10 python3-pip -y

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
