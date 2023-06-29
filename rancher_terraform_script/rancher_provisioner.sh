#!/bin/bash

rancher_version=$1
install_k3s_version=$2

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_success() {
  printf "${GREEN}$1${NC}\n"
}

print_error() {
  printf "${RED}$1${NC}\n"
}


# Function to wait until a command is successful
wait_for_success() {
  local command=$1
  local max_attempts=$2
  local delay=$3

  printf "Waiting for command to succeed: $command\n"

  local attempts=0
  while true; do
    if eval "$command"; then
      print_success "Command succeeded: $command\n"
      break
    else
      attempts=$((attempts + 1))
      if [[ $attempts -ge $max_attempts ]]; then
        print_error "Exceeded maximum attempts. Command failed: $command\n"
        exit 1
      fi
      sleep "$delay"
    fi
  done
}

# Display a blank line
log() {
  local message=$1
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message"
}

# Add Helm repositories for cert-manager 
log "Adding Helm repositories for cert-manager"
helm repo add jetstack https://charts.jetstack.io
helm repo update

log "copy kubeconfig file"
KUBECONFIG=/etc/rancher/k3s/k3s.yaml


# Create namespaces for cert-manager and Rancher
log "Creating namespaces"
kubectl create namespace cert-manager
kubectl create namespace cattle-system

# Wait for 1 second
sleep 1

# Install Cert Manager using Helm
log "Installing Cert Manager"
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --version v1.5.1

# Add Helm repositories for ranchermanager 
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

# Wait for cert-manager pods to initialize
log "Waiting for pods to initialize"
sleep 20 

# Check the rollout status of the cert-manager deployment
log "Checking the rollout status of Cert Manager"
wait_for_success "kubectl -n cert-manager rollout status deployment/cert-manager" 5 5

# Wait for pods to initialize
log "Waiting for pods to initialize"
sleep 10


# Check Kubernetes version
KUBERNETES_VERSION=$(echo "$install_k3s_version" | cut -b 2-5)

# Check if Kubernetes version is 1.25 or higher
if [[ "$KUBERNETES_VERSION" > "1.24" ]]; then
# Append the flag `global.cattle.psp.enabled` to the Helm command

HELM_COMMAND="helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=$(hostname) --set replicas=1 --version=$rancher_version --set global.cattle.psp.enabled=false"
else
  # Use the original Helm command without the psp
  HELM_COMMAND="helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=$(hostname) --set replicas=1 --version=$rancher_version"
fi

# Print the Helm command
echo "Installing Rancher with the following Helm command:"
echo "$HELM_COMMAND"

# Execute the Helm command
eval "$HELM_COMMAND"

# Wait for pods to initialize
log "Waiting for pods to initialize"
sleep 20  

# Get the deployment status of Rancher
log "Getting the deployment status of Rancher"
wait_for_success "kubectl -n cattle-system rollout status deployment/rancher" 5 5

# Get the deployments in the cattle-system namespace
log "Getting deployments in the cattle-system namespace"
kubectl -n cattle-system get deployments rancher


#Get the rancher URL and bootstrap password
log "Getting Rancher URL and password..."
log "~~~"
print_success "Rancher URL = echo https://$(hostname)/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')" 
log "~~~"