#!/bin/bash

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Get the full path to the directory containing this script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
export SCRIPT_DIR

main() {
  while true; do
    choice=$(whiptail --title "Main Menu" --menu "Choose an option for Installations:" 20 60 14 \
      "1" "Install Ubuntu Dependencies" \
      "2" "Install Rancher Manager Using Helm" \
      "3" "Install Rancher Manager Using Docker" \
      "4" "Install RKE" \
      "5" "Install RKE2" \
      "6" "Install k3s" \
      "7" "Install kubectl" \
      "8" "Deploy DNS Server" \
      "9" "Uninstall All" \
      "10" "Create RKE2 Config" \
      "11" "Deploy Private Image Registry" \
      "12" "Install Docker" \
      "13" "Install Helm" \
      "14" "Exit" 3>&1 1>&2 2>&3)

    exitstatus=$?
    if [ $exitstatus != 0 ]; then
      echo "Exiting..." 
      sleep 2
      clear
      exit 0
    fi

    case $choice in
      1) execute_script "install_ubuntu_dependencies.sh" ;;
      2) execute_script "install_rancher_manager_with_helm.sh" ;;
      3) execute_script "install_rancher_manager_with_docker.sh" ;;
      4) execute_script "install_rke.sh" ;;
      5) execute_script "install_rke2.sh" ;;
      6) execute_script "install_k3s.sh" ;;
      7) execute_script "install_kubectl.sh" ;;
      8) execute_script "deploy_dns_server.sh" ;;
      9) execute_script "uninstall_all.sh" ;;
      10) execute_script "create_rke2_config.sh" ;;
      11) execute_script "deploy_private_registry.sh" ;;
      12) execute_script "install_docker.sh" ;;
      13) execute_script "install_helm.sh" ;;
      14) echo "Exiting..."; sleep 2; clear; exit 0 ;;
      *) invalid "Invalid option. Please try again." ;;
    esac
  done
}

execute_script() {
  script_name=$1
  script_path="$SCRIPT_DIR/data/$script_name"

  if [ -f "$script_path" ]; then
    if [ -x "$script_path" ]; then
      whiptail --title "Executing Script" --msgbox "Executing $script_name..." 10 50
      bash "$script_path"
    else
      whiptail --title "Error" --msgbox "The script $script_path is not executable.\nPlease ensure it has the execute permission." 10 50
    fi
  else
    whiptail --title "Error" --msgbox "The script $script_name is not present.\nFeature not integrated." 10 50
  fi
}

invalid() {
  whiptail --title "Invalid Option" --msgbox "Invalid option. Please try again." 10 50
}

main

