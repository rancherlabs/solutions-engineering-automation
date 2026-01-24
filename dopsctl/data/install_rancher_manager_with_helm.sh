#!/bin/bash

# Function to create FQDN based on the host's primary IP
generate_fqdn() {
    # Get the primary IP address of the host
    local primary_ip=$(hostname -I | awk '{print $1}')
    
    # Create the FQDN
    local fqdn="${primary_ip}.sslip.io"
    
    # Return the FQDN
    echo "$fqdn"
}

install_rancher() {
  clear
  echo -e "Installing Rancher Manager using Helm... \n Fetching all available versions from upstream \n \n"
  get_rancher_version
  echo "Installing Rancher $RANCHER_VERSION"
  sleep 3

  # Rancher Server Installation

  # Adding Helm-3
  curl -#L https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  # Add needed helm charts
  helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
  helm repo add jetstack https://charts.jetstack.io

  # Add the cert-manager CRD
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml

  # Helm install jetstack
  helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace

  fqdn=$(generate_fqdn)
  echo "The generated FQDN is: $fqdn"

  # Prompt the user for a hostname with a default value
  read -p "Enter your hostname (default: $fqdn): " hostname_rancher1
  hostname_rancher=${hostname_rancher1:-$fqdn}

  # Display the chosen hostname
  echo "The hostname for Rancher Server will be: $hostname_rancher"


  read -p "Password (default: password): " password_rancher
  newpass=${password_rancher:-"password"}

  # To install a specific version of Rancher
  # Get Rancher version first
  # helm search repo rancher-latest --versions

  helm upgrade -i rancher rancher-latest/rancher --version $RANCHER_VERSION --create-namespace --namespace cattle-system --set hostname=${hostname_rancher} --set bootstrapPassword=${newpass} --set replicas=1
  sleep 5

  kubectl get pods -A

  # Verify Rancher installation
  kubectl -n cattle-system rollout status deploy/rancher
  kubectl -n cattle-fleet-system rollout status deploy/gitjob
  kubectl -n cattle-fleet-system rollout status deploy/fleet-controller
}

get_rancher_version() {
  # Get list of available Rancher versions from GitHub API
  VERSIONS_URL="https://api.github.com/repos/rancher/rancher/releases"
  VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | grep -v 'alpha\|beta' | sort -rV)

  # Display menu of available versions
  echo -e "Please select a Rancher version to install, use option 1 for the latest stable version, or select 'other' to input a custom version: \n"
  select VERSION in "latest" "other" $VERSIONS; do
    if [ "$VERSION" = "other" ]; then
      read -p "Enter custom version: " CUSTOM_VERSION
      RANCHER_VERSION=$CUSTOM_VERSION
      break
    elif [ -n "$VERSION" ]; then
      break
    fi
  done

  # Set RANCHER_VERSION variable
  if [ "$VERSION" = "latest" ]; then
    RANCHER_VERSION=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | grep -v 'alpha\|beta' | head -n 1)
  elif [ "$VERSION" != "other" ]; then
    RANCHER_VERSION=$VERSION
  fi
}

# Call the install_rancher function
install_rancher
