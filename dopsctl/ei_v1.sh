#!/bin/bash

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Get the full path to the directory containing this script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
export SCRIPT_DIR

# Create a single log file for this execution session
CURRENT_DATE=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="/tmp/dopsctl"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/logs_${CURRENT_DATE}_$$.log"

# Log session start
echo "Session started at $(date)" | tee -a "$LOG_FILE"
echo "Logging everything to: $LOG_FILE" | tee -a "$LOG_FILE"

# Function to execute the selected script and log everything
execute_script() {
  script_name=$1
  script_path="$SCRIPT_DIR/data/$script_name"

  # Clear screen after selection
  clear

  # Log execution start in log file only
  start_time=$(date +%s)
  echo -e "\n--------------------------------------" >> "$LOG_FILE"
  echo "Info: Executing $script_name..." | tee -a "$LOG_FILE"
  echo "Start Time: $(date)" >> "$LOG_FILE"

  # Display Log File Name Instead of Start Time
  echo "Log File: $LOG_FILE"

  # Check if the script exists and is executable
  if [ -f "$script_path" ]; then
    if [ -x "$script_path" ]; then
      # Execute script and capture output in log
      bash "$script_path" 2>&1 | tee -a "$LOG_FILE"
    else
      echo "Error: The script $script_path is not executable." | tee -a "$LOG_FILE"
    fi
  else
    echo "Error: $script_name is not present. Feature not integrated." | tee -a "$LOG_FILE"
  fi

  # Log end time only in log file
  end_time=$(date +%s)
  elapsed_time=$((end_time - start_time))
  echo "End Time: $(date)" >> "$LOG_FILE"

  # Display execution time on screen
  echo "Execution Time: ${elapsed_time}s"

  echo "--------------------------------------" >> "$LOG_FILE"

  # Pause for user input before continuing
  read -n 1 -s -r -p "Press any key to continue..."
}

# Function to display the menu
show_menu() {
  clear  # Clear screen before showing menu
  echo "========================================"
  echo " DopsCTL - Automation Script "
  echo "========================================"
  echo "Log File: $LOG_FILE"  # Display log file name every iteration
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
  echo
  echo "   21. Install Rancher Prime"
  echo "H. Fetch Data"
  echo "   22. Fetch Kubernetes cluster info"
  echo "   23. Fetch Kubernetes data"
  echo "I. Quick Rancher Deploy"
  echo "   24. Rancher on RKE"
  echo "   25. Rancher on RKE2"
  echo "   26. Rancher on K3s"
  echo "J. Log data collector"
  echo "   27. Log collection"
  echo "   28. Rancher Log collection"
  echo "   29. Tcpdump on host"
  echo "   30. Tcpdump Inside containers"
  echo
  read -p "Enter your choice [1-30]: " choice
}

# Main function
main() {
  while true; do
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
      22) execute_script "fetch_kubernetes_cluster_info.sh" ;;
      23) execute_script "fetch_kubernetes_data.sh" ;;
      24) execute_script "rancher_on_rke.sh" ;;
      25) execute_script "rancher_on_rke2.sh" ;;
      26) execute_script "rancher_on_k3s.sh" ;;
      27) execute_script "log_collection.sh" ;;
      28) execute_script "rancher_log_collection.sh" ;;
      29) execute_script "tcpdump_host.sh" ;;
      30) execute_script "tcpdump_containers.sh" ;;
      *) 
        echo "Error: Invalid option. Please try again." | tee -a "$LOG_FILE"
        sleep 2
        ;;
    esac
  done
}

# Start the main function
main
