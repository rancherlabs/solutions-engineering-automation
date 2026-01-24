#!/bin/bash
install_kubectl() {
  clear
  echo -e "Installing Helm/kubectl... \n Fetching all the avaialble version from upstream \n \n"

  get_kubectl_version
  echo "Installing Kubectl $KUBECTL_VERSION"
  sleep 3

##KUBECTL_VERSION="v1.22.0"
architecture=$(uname -m)

if [ "$architecture" == "x86_64" ]; then
    echo "AMD architecture detected. Continuing with AMD-specific actions..."
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
else
    echo "ARM architecture detected. Continuing with ARM-specific actions..."
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/arm64/kubectl"
fi

  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  kubectl version --client
  sleep 5
}

get_kubectl_version () {
  # Get list of available kubectl versions from GitHub API
  VERSIONS_URL="https://api.github.com/repos/kubernetes/kubectl/tags"
  VERSIONS=$(curl -s $VERSIONS_URL | grep '"name":' | cut -d '"' -f 4 | sort -rV)

  # Append "stable" option by fetching the stable version from the given URL
  STABLE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  #VERSIONS+=" stable"
  VERSIONS="Stable $VERSIONS"




  # Display menu of available versions
  echo -e "Please select a kubectl version or use option 1 for stable version: \n"
  select VERSION in $VERSIONS; do
    if [ -n "$VERSION" ]; then
      break
    fi
  done

  # Set KUBECTL_VERSION variable based on the selected version
  if [ "$VERSION" == "Stable" ]; then
    KUBECTL_VERSION=$STABLE_VERSION
  else
    KUBECTL_VERSION=$VERSION
  fi
}
install_kubectl
