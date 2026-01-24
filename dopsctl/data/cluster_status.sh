#!/bin/bash

# Define colors for better readability
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Separator function
print_separator() {
  echo -e "\n${BLUE}========================================${RESET}"
  echo -e "${BLUE}$1${RESET}"
  echo -e "${BLUE}========================================${RESET}\n"
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo -e "${RED}kubectl is not installed. Please install it and ensure it is configured.${RESET}"
  exit 1
fi

# Kubernetes Cluster Info
print_separator "KUBERNETES CLUSTER INFO"
kubectl cluster-info

# Kubernetes Version
print_separator "KUBERNETES VERSION"
server_version=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')
echo -e "Server Version: $server_version"

# Nodes Status
print_separator "NODES STATUS"
kubectl get nodes -o wide

# Pods Count by Status
print_separator "PODS COUNT BY STATUS"
kubectl get pods --all-namespaces --no-headers | awk '{counts[$4]++} END {for (status in counts) print status ": " counts[status]}'

# Top Nodes (CPU and Memory Usage)
print_separator "TOP NODES (CPU and MEMORY USAGE)"
kubectl top nodes

# Top Pods (CPU and Memory Usage)
print_separator "TOP PODS (CPU and MEMORY USAGE)"
kubectl top pods --all-namespaces

# ETCD and API Server Health
print_separator "ETCD AND API SERVER STATUS"
kubectl get componentstatuses

# Cluster Events (Last 10)
print_separator "LAST 10 CLUSTER EVENTS"
kubectl get events --all-namespaces --sort-by='.metadata.creationTimestamp' | tail -n 10

# Logs for RKE2 Server (Last 5 Entries)
if [[ "$server_version" == *"rke2"* ]]; then
  print_separator "LAST 5 LOGS FROM RKE2 SERVER"
  
  echo -e "${YELLOW}RKE2-Server Logs (journalctl):${RESET}"
  journalctl -u rke2-server | tail -n 5 | tee /tmp/rke2-server.log
  grep -E "Warning|Error" /tmp/rke2-server.log || echo -e "${GREEN}No warnings or errors found in RKE2 server logs.${RESET}"

  echo -e "\n${YELLOW}Containerd Logs:${RESET}"
  tail -n 5 /var/lib/rancher/rke2/agent/containerd/containerd.log | tee /tmp/containerd.log
  grep -E "Warning|Error" /tmp/containerd.log || echo -e "${GREEN}No warnings or errors found in containerd logs.${RESET}"

  echo -e "\n${YELLOW}Kubelet Logs:${RESET}"
  tail -n 5 /var/lib/rancher/rke2/agent/logs/kubelet.log | tee /tmp/kubelet.log
  grep -E "Warning|Error" /tmp/kubelet.log || echo -e "${GREEN}No warnings or errors found in kubelet logs.${RESET}"
else
  echo -e "${YELLOW}RKE2-specific logs are not applicable as this is not an RKE2 cluster.${RESET}"
fi

# End of Script

echo 
echo
echo -e "${GREEN}Kubernetes cluster status check completed.${RESET}"

