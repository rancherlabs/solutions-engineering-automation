#!/bin/bash

install_k3s() {
  clear
  echo -e "Installing k3s... \nFetching latest available versions \n \n"
  get_k3s_version
  echo "$K3S_VERSION"
  sleep 2

  if [ "$K3S_VERSION" == "Other" ]; then
    read -p "Enter the k3s version you want to install: " CUSTOM_VERSION

    if ! validate_k3s_version "$CUSTOM_VERSION"; then
      echo
      echo "Version not found: $CUSTOM_VERSION"
      sleep 2
      echo "Verify k3s Version i.e $CUSTOM_VERSION"
      sleep 5
      clear

      install_k3s
    fi

    K3S_VERSION=$CUSTOM_VERSION
  fi

  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION sh -

  # Verify k3s installation
  sudo k3s kubectl get nodes

  mkdir -p ~/.kube/
  cp /etc/rancher/k3s/k3s.yaml  ~/.kube/config
  #export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

  for i in $(kubectl get deploy -n kube-system --no-headers | awk '{print $1}'); do
    kubectl -n kube-system rollout status deploy $i
  done
}

function validate_k3s_version() {
  local K3S_VERSION=$1

    if [ "$architecture" == "x86_64" ]; then
    echo "AMD architecture detected. Continuing with AMD-specific actions..."
    RKE_arc=k3s
  else
    echo "ARM architecture detected. Continuing with ARM-specific actions..."
    RKE_arc=k3s-arm64
  fi

  K3S_DOWNLOAD_URL="https://github.com/k3s-io/k3s/releases/download/$K3S_VERSION/$RKE_arc"

  if wget --spider "$K3S_DOWNLOAD_URL" 2>/dev/null; then
    return 0  # URL is reachable
  else
    return 1  # URL is not reachable
  fi
}

function get_k3s_version {
  # Get list of available k3s versions from GitHub API
  VERSIONS_URL="https://api.github.com/repositories/135516270/releases"
  VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | sort -rV)

  # Add "Latest" and "Other" options to the list
  VERSIONS="Latest Other $VERSIONS"

  # Display menu of available versions
  echo -e "Please select a k3s version to install or choose 'Other' to enter a specific version: \n"
  select VERSION in $VERSIONS ; do
    if [ -n "$VERSION" ]; then
      break
    fi
  done

  # Set K3S_VERSION variable
  case $VERSION in
    "Latest")
      K3S_VERSION=$(curl -s $VERSIONS_URL | grep '"name":' | cut -d '"' -f 4 | head -n 1)
      ;;
    "Other")
      K3S_VERSION="Other"
      ;;
    *)
      K3S_VERSION=$VERSION
      ;;
  esac
}
clear
echo "Installing k3s..."
sleep 2
install_k3s
