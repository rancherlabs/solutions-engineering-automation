#!/bin/bash
uninstall () {

echo "Choose the components to uninstall/clean:"
  echo "1. RKE2"
  echo "2. K3s"
  echo "3. Docker"
  echo "4. All"

  read -p "Enter the number corresponding to your choice: " CHOICE

  case $CHOICE in
    1)
      # Uninstall RKE2
      /usr/local/bin/rke2-uninstall.sh
      ;;
    2)
      # Uninstall K3s
      /usr/local/bin/k3s-uninstall.sh
      ;;
    3)
      # Clean Docker
      for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove $pkg
      done
      sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
      sudo rm -rf /var/lib/docker
      sudo rm -rf /var/lib/containerd
      ;;
    4)
      # Uninstall all
      /usr/local/bin/rke2-uninstall.sh
      /usr/local/bin/k3s-uninstall.sh
      for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove $pkg
      done
      sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
      sudo rm -rf /var/lib/docker
      sudo rm -rf /var/lib/containerd
      ;;
    *)
      echo "Invalid choice. Exiting."
      ;;
  esac





}
uninstall


