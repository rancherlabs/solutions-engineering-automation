#!/bin/bash

# Function to create FQDN based on the host's primary IP
generate_fqdn() {
    local primary_ip=$(hostname -I | awk '{print $1}')
    local fqdn="${primary_ip}.sslip.io"
    echo "$fqdn"
}

# Function to install Rancher
install_rancher() {
    clear

    echo "Generating Fully Qualified Domain Name (FQDN)..."
    fqdn=$(generate_fqdn)
    echo "The generated FQDN is: $fqdn"

    # Prompt the user for a hostname with a default value
    echo -e "\nLet's set up the hostname for Rancher."
    read -p "Enter your hostname (default: $fqdn): " hostname_rancher1
    hostname_rancher=${hostname_rancher1:-$fqdn}
    echo "The hostname for Rancher Server will be: https://$hostname_rancher"

    # Prompt for Rancher password
    echo -e "\nLet's set the password for Rancher."
    read -p "Password (default: password): " password_rancher
    newpass=${password_rancher:-"password"}
    echo "Password for Rancher has been set."

    echo -e "\nInstalling Rancher Manager using Helm..."
    echo "Fetching all available Rancher versions from upstream..."
    get_rancher_version
    echo "Selected Rancher version: $RANCHER_VERSION"
    sleep 3

    echo -e "\nInstalling Helm..."
    # Check if Helm is installed
    if ! command -v helm &> /dev/null; then
        echo "Helm is not installed. Installing Helm..."
        curl -#L https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || { echo "Failed to install Helm"; exit 1; }
    else
        echo "Helm is already installed."
    fi

    echo -e "\nAdding Helm repositories..."
    # Add needed helm charts
    helm repo add rancher-latest https://releases.rancher.com/server-charts/latest || { echo "Failed to add Rancher Helm repo"; exit 1; }
    helm repo add jetstack https://charts.jetstack.io || { echo "Failed to add Jetstack Helm repo"; exit 1; }

    echo -e "\nFetching cert-manager version..."
    get_cert_manager_version
    echo "Selected cert-manager version: $cert_version"
    sleep 3

    echo -e "\nApplying cert-manager CRDs..."
    # Add the cert-manager CRD
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/$cert_version/cert-manager.crds.yaml || { echo "Failed to apply cert-manager CRDs"; exit 1; }

    echo -e "\nInstalling cert-manager using Helm..."
    # Helm install jetstack
    helm upgrade -i cert-manager jetstack/cert-manager --version $cert_version --namespace cert-manager --create-namespace || { echo "Failed to install cert-manager"; exit 1; }

    echo -e "\nInstalling Rancher..."
    # Install Rancher
    helm upgrade -i rancher rancher-latest/rancher --version $RANCHER_VERSION --create-namespace --namespace cattle-system --set hostname=${hostname_rancher} --set bootstrapPassword=${newpass} --set replicas=1 || { echo "Failed to install Rancher"; exit 1; }
    sleep 5

    echo -e "\nFetching Kubernetes pod status..."
    kubectl get pods -A

    echo -e "\nVerifying Rancher installation..."
    # Verify Rancher installation
    kubectl -n cattle-system rollout status deploy/rancher 

    echo -e "\nRancher installation completed successfully!"
}

# Function to get the Rancher version
get_rancher_version() {
    echo -e "\nFetching available Rancher versions..."
    VERSIONS_URL="https://api.github.com/repos/rancher/rancher/releases"
    VERSIONS=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | grep -v 'alpha\|beta' | sort -rV)

    # Display menu of available versions
    echo -e "\nPlease select a Rancher version to install:"
    echo "Use option 1 for the latest stable version, or select 'other' to input a custom version."
    select VERSION in "latest" "other" $VERSIONS; do
        if [ "$VERSION" = "other" ]; then
            read -p "Enter custom version: " CUSTOM_VERSION
            RANCHER_VERSION=$CUSTOM_VERSION
            break
        elif [ -n "$VERSION" ]; then
            RANCHER_VERSION=$VERSION
            break
        else
            echo "Invalid selection. Please choose a valid option."
        fi
    done

    if [ "$VERSION" = "latest" ]; then
        RANCHER_VERSION=$(curl -s $VERSIONS_URL | grep '"tag_name":' | cut -d '"' -f 4 | grep -v 'alpha\|beta' | head -n 1)
    fi
}

# Function to get the cert-manager version
get_cert_manager_version() {
    echo -e "\nFetching available cert-manager versions..."
    cert_version=$(helm search repo jetstack -l | grep '^jetstack/cert-manager ' | awk '{print $2}' | head -n 1)

    # Display available options to the user
    PS3="Choose an option: "
    select option in "Go with latest cert-manager version: $cert_version" "Select custom cert-manager version"; do
        case $REPLY in
            1)
                echo "Selected latest cert-manager version: $cert_version"
                return
                ;;
            2)
                break
                ;;
            *)
                echo "Invalid option. Please select a valid option."
                ;;
        esac
    done

    echo -e "\nFetching cert-manager versions..."
    CERT_VER=$(helm search repo jetstack -l | grep '^jetstack/cert-manager ' | awk '{print $2}')

    # Prompt user to select a version or enter a custom one
    select VERSION in "latest" "other" $CERT_VER; do
        if [ "$VERSION" = "other" ]; then
            read -p "Enter custom version: " CUSTOM_VERSION
            cert_version=$CUSTOM_VERSION
            break
        elif [ -n "$VERSION" ]; then
            cert_version=$VERSION
            break
        else
            echo "Invalid selection. Please choose a valid option."
        fi
    done

    echo "Selected cert-manager version: $cert_version"
}

# Call the install_rancher function
install_rancher
