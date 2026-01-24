#!/bin/bash

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Get the full path to the directory containing this script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
export SCRIPT_DIR

# Function to execute the selected script
execute_script() {
  script_name=$1
  script_path="$SCRIPT_DIR/data/$script_name"

  echo; echo
  # Check if the script is present and executable
  if [ -f "$script_path" ]; then
    if [ -x "$script_path" ]; then
      echo "Executing $script_name..."
      sleep 1
      bash "$script_path"
    else
      echo "Error: The script $script_path is not executable."
      echo "Please ensure it has the execute permission."
    fi
  else
    echo "Error: $script_name is not present. Feature not integrated."
  fi

  # Display empty lines after executing the script
  sleep 2
}

# Function to handle invalid choices
invalid() {
  echo "--------------------------------------"
  echo "Invalid option. Please try again."
  sleep 2
}

# Function to display the menu
show_menu() {
  echo "Please select an option for Installations:"
  echo "A. Install Kubernetes"
  echo "   1. Install rke"
  echo "   2. Install rke2"
  echo "   3. Install k3s"
  echo "   4. Install k8s"
  echo "B. Install Rancher"
  echo "   5. Install Rancher via Helm"
  echo "   6. Install Rancher via Docker"
  echo "C. Container Runtime"
  echo "   7. Install Docker"
  echo "   8. Install containerd"
  echo "   9. Install crio"
  echo "   10. Install podman"
  echo "D. Utility"
  echo "   11. Install kubectl"
  echo "   12. Install Helm"
  echo "E. Services"
  echo "   13. Deploy DNS Server"
  echo "   14. Deploy Proxy"
  echo "F. Deploy"
  echo "   15. Deploy Private Image Registry"
  echo "   16. Deploy LB via HAproxy"
  echo "   17. Deploy LB via Nginx"
  echo "   18. Deploy LB via Traefik"
  echo "   99. Deploy Sample Webserver"
  echo "G. Certs"
  echo "   19. Configure SSL Cert"
  echo "   20. Install Let's Encrypt"
  echo; echo; echo
  echo "   21. Install Rancher Prime"
  echo "H. Fetch Data"
  echo "   2X. Fetch Platform Data"
  echo "   22. Fetch kubernetes cluster info"
  echo "   23. Fetch kubernetes data"
  echo "I. Quick Rancher Deploy"
  echo "   24. Rancher on RKE"
  echo "   25. Rancher on RKE2"
  echo "   26. Rancher on K3s"
  echo "J. Log data collector"
  echo "   26. Log collection"
  echo "   27. Rancher Log collection"
  echo "   28. Tcpdump on host"
  echo "   29. Tcpdump Inside containers"
  read -p "Enter your choice [1-20]: " choice
}

# Main function
main() {
  while true; do
    sleep 1
    clear
    show_menu
    case $choice in
      1) execute_script "install_rke.sh" ;;
      2) execute_script "install_rke2.sh" ;;
      3) execute_script "install_k3s.sh" ;;
      4) execute_script "install_kubernetes.sh" ;;
      5) execute_script "rancher_helm.sh" ;;
      6) execute_script "install_rancher_manager_with_docker.sh" ;;
      7) execute_script "install_docker.sh" ;;
      8) execute_script "install_containerd.sh" ;;
      9) execute_script "install_crio.sh" ;;
      10) execute_script "install_podman.sh" ;;
      11) execute_script "install_kubectl.sh" ;;
      12) execute_script "install_helm.sh" ;;
      13) execute_script "deploy_dns_server.sh" ;;
      14) execute_script "deploy_proxy.sh" ;;
      15) execute_script "deploy_private_registry.sh" ;;
      16) execute_script "deploy_lb_haproxy.sh" ;;
      17) execute_script "deploy_lb_nginx.sh" ;;
      18) execute_script "deploy_lb_traefik.sh" ;;
      19) execute_script "configure_ssl_cert.sh" ;;
      20) execute_script "install_lets_encrypt.sh" ;;
      21) execute_script "install_rancher_prime.sh" ;;
      99) execute_script "deploy_sample_webserver_khushal.sh" ;;

      *) invalid ;;
    esac
  done
}

# Start the main function
main
