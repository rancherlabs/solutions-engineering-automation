#!/bin/bash
### This script is specially designed for Ubuntu OS

# Function to display menu and prompt user for input
show_menu () {
  echo "Please select an option for Installations:"
  echo "1. Install dependencies in Ubuntu OS"
  echo "2. Install Rancher Manager Using Helm"
  echo "3. Install Rancher Manager Using Docker"
  echo "4. Install RKE"
  echo "5. Install RKE2"
  echo "6. Install k3s"
  echo "7. Install Helm/kubectl"
  echo "8. Deploy DNS Server"
  echo "9. Uninstall All"
  echo "10. Exit"
  read -p "Enter your choice [1-10]: " choice
}

invalid() {
  clear
  echo -e "Invalid option. Please try again. \n"
  sleep 1
}

configure_ubuntu() {
  echo "Configuring Ubuntu OS for Rancher Ready..."
# Ubuntu instructions
# stop the software firewall
systemctl disable --now ufw

# get updates, install nfs, and apply

apt-mark hold linux-image-*
apt update
apt install nfs-common curl -y
apt upgrade -y
apt-mark unhold linux-image-*
# clean up
apt autoremove -y  

}

install_rancher() {
clear  
echo -e "Installing Rancher Manager using Helm... \n Fetching all the avaialble version from upstream \n \n"
get_rancher_version
echo "Installing Rancher $RANCHER_VERSION"
sleep 3

 ### Rancher Server Installation


# Adding Helm-3

curl -#L https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# add needed helm charts
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add jetstack https://charts.jetstack.io



# still on  rancher1 master, worker not configured yet
# add the cert-manager CRD
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml

# helm install jetstack
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace


### Installing Rancher Server


read -p "Enter your hostname: " hostname_rancher
echo "Your provided hostname is $hostname_rancher"

read -p "Password: " password_rancher

### To install specific version rancher
## Get rancher version first
# helm search repo rancher-latest --versions

helm upgrade -i rancher rancher-latest/rancher --version $RANCHER_VERSION  --create-namespace --namespace cattle-system --set hostname=${hostname_rancher} --set bootstrapPassword=${password_rancher} --set replicas=1
sleep 5

kubectl get pods -A

# Verify Rancher installation
kubectl -n cattle-system rollout status deploy/rancher

}

get_rancher_version () {
  # Get list of available Rancher versions from GitHub API
  VERSIONS_URL="https://api.github.com/repos/rancher/rancher/releases"
  VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | grep -v 'alpha\|beta' | sort -rV)

  # Display menu of available versions
  echo -e "Please select a Rancher version to install or use option 1 for the latest stable version: \n"
  select VERSION in "latest" $VERSIONS; do
    if [ -n "$VERSION" ]; then
      break
    fi
  done

  # Set RANCHER_VERSION variable
  if [ "$VERSION" = "latest" ]; then
    RANCHER_VERSION=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | grep -v 'alpha\|beta' | head -n 1)
  else
    RANCHER_VERSION=$VERSION
  fi
}


docker_rancher() {
echo "Installing Rancher Manager using Docker..."
curl -fsSL get.docker.com | bash
systemctl enable docker
docker run --privileged -d --restart=no -p 8080:80 -p 8443:443 -p 36443:6443 -v rancher:/var/lib/rancher  rancher/rancher

  

}






install_rke() {
  clear
  echo -e "Installing RKE... \n Fetching all the avaialble version from upstream \n \n"
  # Add your installation logic for RKE here
  get_rke_version
  echo "$RKE_VERSION"
  sleep 3
  # Download and install RKE binary
  RKE_DOWNLOAD_URL="https://github.com/rancher/rke/releases/download/$RKE_VERSION/rke_linux-amd64"
  curl -LO $RKE_DOWNLOAD_URL
  sudo install rke_linux-amd64 /usr/local/bin/rke

  # Verify RKE installation
  rke --version
  sleep 3
}


function get_rke_version {
  # Get list of available RKE versions from GitHub API
  VERSIONS_URL="https://api.github.com/repos/rancher/rke/releases"
  VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | sort -rV)

  # Add "Latest" option to the list
  VERSIONS="Latest $VERSIONS"

  # Display menu of available versions
  echo -e "Please select an RKE version to install or use option 1 for the latest stable version : \n"
  select VERSION in $VERSIONS; do
    if [ -n "$VERSION" ]; then
      break
    fi
  done

  # Check if "Latest" option was selected
  if [ "$VERSION" = "Latest" ]; then
    # Fetch the latest version from the GitHub API
    LATEST_VERSION=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | head -n 1)
    RKE_VERSION=$LATEST_VERSION
  else
    # Set RKE_VERSION variable to the selected version
    RKE_VERSION=$VERSION
  fi
}





install_rke2_apt_get() {
clear

architecture=$(uname -m)

if [ "$architecture" == "x86_64" ]; then
    echo "AMD architecture detected. Continuing with AMD-specific actions..."
    # Add your AMD-specific commands or actions here
else
    echo "Unsupported architecture detected. Quitting..."
    exit 1
fi

echo -e "Installing RKE2 Server ... \n Fetching all the avaialble version from upstream \n \n"
# Add your installation logic for RKE2 Server using apt here
get_rke2_version
echo "$RKE2_VERSION"
sleep 2

## Using script not apt
# On rancher1
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server INSTALL_RKE2_CHANNEL=$RKE2_VERSION sh -

# start and enable for restarts -
echo -e "\n initializing  RKE2 Server"
systemctl enable --now rke2-server.service

systemctl status rke2-server --no-pager

cp $(find /var/lib/rancher/rke2/data/ -name kubectl) /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

mkdir ~/.kube/
cp /etc/rancher/rke2/rke2.yaml  ~/.kube/config
#export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

kubectl version --short

kubectl get node -o wide
sleep 8

for i in $(kubectl get deploy -n kube-system --no-headers | awk '{print $1}'); do  kubectl -n kube-system rollout status deploy $i; done

sleep 2

}

# Function to display menu for all avaialble RKE2 version and get user's choice
function get_rke2_version {
  # Get list of available RKE2 versions from GitHub API
  VERSIONS_URL="https://api.github.com/repos/rancher/rke2/releases"
  VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | sort -rV)

  # Add "Latest" option to the list
  VERSIONS="Latest $VERSIONS"

  # Display menu of available versions
  echo -e "Please select an RKE2 version to install or use option 1 for the latest stable version: \n"
  select VERSION in $VERSIONS; do
    if [ -n "$VERSION" ]; then
      break
    fi
  done

  # Check if "Latest" option was selected
  if [ "$VERSION" = "Latest" ]; then
    # Fetch the latest version from the GitHub API
    LATEST_VERSION=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | head -n 1)
    RKE2_VERSION=$LATEST_VERSION
  else
    # Set RKE2_VERSION variable to the selected version
    RKE2_VERSION=$VERSION
  fi
}


install_k3s() {
  clear  
  echo -e "Installing k3s... \n Fetching all the avaialble version from upstream \n \n"
  get_k3s_version
  echo "$K3S_VERSION"
  sleep 2

  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION sh -

  # Verify k3s installation
  sudo k3s kubectl get nodes

  mkdir ~/.kube/
  cp /etc/rancher/k3s/k3s.yaml  ~/.kube/config
  #export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

  for i in $(kubectl get deploy -n kube-system --no-headers | awk '{print $1}'); do  kubectl -n kube-system rollout status deploy $i; done

}

function get_k3s_version {
  # Get list of available k3s versions from GitHub API
  VERSIONS_URL="https://api.github.com/repositories/135516270/releases"
  VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | sort -rV)

  # Display menu of available versions
  echo -e "Please select a k3s version to install or use option 1 for the latest stable version: \n"
  select VERSION in "latest" $VERSIONS ; do
    if [ -n "$VERSION" ]; then
      break
    fi
  done

  # Set K3S_VERSION variable
  if [ "$VERSION" = "latest" ]; then
    K3S_VERSION=$(curl -s $VERSIONS_URL | grep '"name":' | cut -d '"' -f 4 | head -n 1)
  else
    K3S_VERSION=$VERSION
  fi
}

install_tools() {
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



configure_dns() {
  echo "Deploying DNS server..."
}


if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

uninstall () {

/usr/local/bin/rke2-uninstall.sh
/usr/local/bin/k3s-uninstall.sh


}
# Loop through menu until user selects "9. Exit"
while true; do
  sleep 1
  clear
  show_menu
  case $choice in
    1) configure_ubuntu ;;
    2) install_rancher ;;
    3) docker_rancher ;;
    4) install_rke ;;
    5) install_rke2_apt_get ;;
    6) install_k3s ;;
    7) install_tools ;;
    8) configure_dns ;;
    9) uninstall ;;
    10) clear && exit 0 ;;
    *) invalid ;;
    # *) echo "Invalid option. Please try again." ;;
  esac
done
