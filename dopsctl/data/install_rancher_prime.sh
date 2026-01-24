#!/bin/bash

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
 helm repo add rancher-prime https://charts.rancher.com/server-charts/prime
kubectl create ns cattle-system
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.1
kubectl get pods --namespace cert-manager

  # Installing Rancher Server
  read -p "Enter your hostname: " hostname_rancher
  echo "Your provided hostname is $hostname_rancher"

  #read -p "Password: " password_rancher
  #read -p "Password [default=password]: " -i "password" password_rancher

  read -p "Password (default: password): " password_rancher
  newpass=${password_rancher:-"password"}

  # To install a specific version of Rancher
  # Get Rancher version first
  # helm search repo rancher-latest --versions

  #helm upgrade -i rancher rancher-latest/rancher --version $RANCHER_VERSION --create-namespace --namespace cattle-system --set hostname=${hostname_rancher} --set bootstrapPassword=${password_rancher} --set replicas=1
  helm install rancher rancher-prime/rancher --version $RANCHER_VERSION --namespace cattle-system --set hostname=${hostname_rancher} --set rancherImage="registry.rancher.com/rancher/rancher" --set bootstrapPassword=${newpass}
  kubectl -n cattle-system rollout status deploy/rancher
  kubectl -n cattle-system get deploy rancher
  
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
