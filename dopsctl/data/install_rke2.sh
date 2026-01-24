install_rke2() {
  clear

  echo -e "Installing RKE2 Server ... \nFetching latest available versions  \n \n"
  # Add your installation logic for RKE2 Server using apt here
  get_rke2_version
  echo "$RKE2_VERSION"
  sleep 2

  ## Using script not apt
  # On rancher1
  curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server INSTALL_RKE2_CHANNEL=$RKE2_VERSION sh -

  # start and enable for restarts -
  echo -e "\nInitializing RKE2 Server"
  systemctl enable --now rke2-server.service

  systemctl status rke2-server --no-pager

  cp "$(find /var/lib/rancher/rke2/data/ -name kubectl)" /usr/local/bin/kubectl
  chmod +x /usr/local/bin/kubectl

  mkdir -p ~/.kube/
  cp /etc/rancher/rke2/rke2.yaml  ~/.kube/config
  #export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

  kubectl version --short

  kubectl get node -o wide
  sleep 8

  for i in $(kubectl get deploy -n kube-system --no-headers | awk '{print $1}'); do
    kubectl -n kube-system rollout status deploy $i
  done

 sleep 5
 kubectl wait --for=condition=Available deployment --timeout=2m -n kube-system --all

  sleep 2
}

# Function to display a menu for all available RKE2 versions and get the user's choice


validate_url() {
  local RKE_VERSION=$1

  if [ "$architecture" == "x86_64" ]; then
    echo "AMD architecture detected. Continuing with AMD-specific actions..."
    RKE_arc=rke2.linux-amd64
  else
    echo "ARM architecture detected. Continuing with ARM-specific actions..."
    RKE_arc=rke2.linux-arm64
  fi

  RKE_DOWNLOAD_URL="https://github.com/rancher/rke2/releases/download/$RKE_VERSION/$RKE_arc"

  if wget --spider "$RKE_DOWNLOAD_URL" 2>/dev/null; then
    return 0  # URL is reachable
  else
    return 1  # URL is not reachable
  fi
}

function get_rke2_version {
  # Get the system architecture
  architecture=$(uname -m)

  # Get list of available RKE2 versions from GitHub API
  VERSIONS_URL="https://api.github.com/repos/rancher/rke2/releases"

  if [ "$architecture" == "x86_64" ] || [ "$architecture" == "amd64" ]; then
    VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | sort -rV)
  elif [ "$architecture" == "arm" ] || [ "$architecture" == "aarch64" ]; then
    VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | grep -E '^v(1\.27\.|1\.28\.)' | sort -rV)
  else
    echo "Unsupported architecture '$architecture' detected. Quitting..."
    exit 1
  fi

  # Add "Latest" and "Other" options to the list
  VERSIONS="Latest Other $VERSIONS"

  while true; do
    # Display menu of available versions
    echo -e "Please select an RKE2 version to install or choose 'Other' to enter a specific version: \n"
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
        RKE2_VERSION=$LATEST_VERSION
        break
        ;;
      "Other")
        # Prompt the user to enter a specific version
        read -p "Enter the RKE2 version you want to install: " CUSTOM_VERSION

        # Validate the entered version
        if ! validate_url "$CUSTOM_VERSION"; then
          echo
	  echo
	  echo "Version not found: $CUSTOM_VERSION"
          sleep 2
          echo "Verify RKE Version i.e  $CUSTOM_VERSION"
          sleep 5
	  clear
          continue  # Continue the loop to prompt the user again
        fi

        # If validation is successful, break out of the loop
        RKE2_VERSION=$CUSTOM_VERSION
        break
        ;;
      *)
        # Set RKE2_VERSION variable to the selected version
        RKE2_VERSION=$VERSION
        break
        ;;
    esac
  done
}
clear
echo "Installing Rke2..."
sleep 2


install_rke2
