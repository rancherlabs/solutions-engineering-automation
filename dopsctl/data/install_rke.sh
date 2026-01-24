#!/bin/bash

validate_url() {
  local url=$1
  if wget --spider "$url" 2>/dev/null; then
    return 0  # URL is reachable
  else
    return 1  # URL is not reachable
  fi
}


install_rke() {
  clear
  echo -e "Installing RKE... \n Fetching latest avaialble versions \n \n"
  # Add your installation logic for RKE here
  get_rke_version
  echo "$RKE_VERSION"
  sleep 3
  # Download and install RKE binary
  architecture=$(uname -m)

if [ "$architecture" == "x86_64" ]; then
    echo "AMD architecture detected. Continuing with AMD-specific actions..."
      RKE_arc=rke_linux-amd64
else
    echo "ARM architecture detected. Continuing with ARM-specific actions..."
      RKE_arc=rke_linux-arm64
fi

  RKE_DOWNLOAD_URL="https://github.com/rancher/rke/releases/download/$RKE_VERSION/$RKE_arc"

  if ! validate_url "$RKE_DOWNLOAD_URL"; then
    echo "Invalid URL: $RKE_DOWNLOAD_URL"
    sleep 2
    echo " Verify RKE Version i.e  $RKE_VERSION"
    sleep 5
    install_rke
    #exit 1
  fi
 
  
  curl -LO $RKE_DOWNLOAD_URL
  sudo install $RKE_arc /usr/local/bin/rke

  # Verify RKE installation
  rke --version
  sleep 3
  ssh_config_rke

  sleep 1

  rke config
  rke up
  mkdir ~/.kube
  cp kube_config_cluster.yml ~/.kube/config

  sleep 5

kubectl cluster-info
kubectl get nodes
kubectl get cs
}

function ssh_config_rke {

ufw disable
swapoff -a; sed -i '/swap/d' /etc/fstab

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


# Define the key type and key size
KEY_TYPE="rsa"
KEY_SIZE="2048"

# Define the key file paths
PRIVATE_KEY_PATH="$HOME/.ssh/id_rsa"
PUBLIC_KEY_PATH="$HOME/.ssh/id_rsa.pub"
AUTHORIZED_KEYS_PATH="$HOME/.ssh/authorized_keys"

# Check if the SSH key pair already exists
#if [ -f "$PRIVATE_KEY_PATH" ]; then
#    echo "SSH key pair already exists at $PRIVATE_KEY_PATH"
#    exit 1
#fi

# Generate a new SSH key pair or overwirte

ssh-keygen -t "$KEY_TYPE" -b "$KEY_SIZE" -f "$PRIVATE_KEY_PATH" -N "" -q
# Check if the key generation was successful
if [ $? -ne 0 ]; then
    echo "Failed to generate SSH key pair"
    exit 1
fi

# Append the public key to the authorized_keys file
if [ -f "$AUTHORIZED_KEYS_PATH" ]; then
    cat "$PUBLIC_KEY_PATH" >> "$AUTHORIZED_KEYS_PATH"
    echo "Public key appended to $AUTHORIZED_KEYS_PATH"
else
    echo "WARNING: authorized_keys file not found. Public key not added."
fi

# Display a success message
echo "SSH key pair generated"

}
function get_rke_version {
  # Get list of available RKE versions from GitHub API
  VERSIONS_URL="https://api.github.com/repos/rancher/rke/releases"
  VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | sort -rV)

  # Add "Latest" and "Other" options to the list
  VERSIONS="Latest Other $VERSIONS"

  # Display menu of available versions
  echo -e "Please select an RKE version to install or choose 'Other' to enter a specific version: \n"
  select VERSION in $VERSIONS; do
    if [ -n "$VERSION" ]; then
      break
    fi
  done

  # Check if "Latest" or "Other" option was selected
  case $VERSION in
    "Latest")
      # Fetch the latest version from the GitHub API
      LATEST_VERSION=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | head -n 1)
      RKE_VERSION=$LATEST_VERSION
      ;;
    "Other")
      # Prompt the user to enter a specific version
      read -p "Enter the RKE version you want to install: " CUSTOM_VERSION
      RKE_VERSION=$CUSTOM_VERSION
      ;;
    *)
      # Set RKE_VERSION variable to the selected version
      RKE_VERSION=$VERSION
      ;;
  esac
}
clear
echo "Installing RKE..."
sleep 2

install_rke
