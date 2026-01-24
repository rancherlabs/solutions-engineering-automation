#!/bin/bash
configure_ubuntu() {
  echo "Configuring Ubuntu OS for Rancher Ready..."
# Ubuntu instructions
# stop the software firewall
systemctl disable --now ufw

# get updates, install nfs, and apply

apt-mark hold linux-image-*
apt update
apt install nfs-common curl -y
apt upgrade -y
apt-mark unhold linux-image-*
# clean up
apt autoremove -y

}
configure_ubuntu
