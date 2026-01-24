#!/bin/bash

# Function to generate FQDN
generate_fqdn() {
    local primary_ip=$(hostname -I | awk '{print $1}')
    local fqdn="pir.${primary_ip}.sslip.io"
    echo "$fqdn"
}

# Function to check if Docker is installed and running
check_docker() {
  if ! docker info &> /dev/null; then
    echo "Docker is not installed or the Docker daemon is not running."
    read -p "Do you want to install Docker? (y/n): " INSTALL_DOCKER
    if [ "$INSTALL_DOCKER" == "y" ]; then
      echo "Installing Docker..."
      execute_script "install_docker.sh"
    else
      echo "Exiting script. Docker is required for this operation."
      exit 1
    fi
  fi
}

execute_script() {
  script_name=$1
  script_path="$SCRIPT_DIR/data/$script_name"

  if [ -f "$script_path" ]; then
    if [ -x "$script_path" ]; then
      echo "Executing $script_name..."
      sleep 1
      bash "$script_path"
    else
      echo "Error: The script $script_path is not executable."
      echo "Please ensure it has the execute permission."
    fi
  else
    echo "Error: $script_name is not present. Feature not integrated."
  fi
  sleep 2
}

# Check if Docker is installed and running
check_docker

# Generate FQDN for Private Image Registry
fqdn=$(generate_fqdn)
echo
echo "The generated FQDN is: $fqdn"
echo
# Prompt the user for the registry FQDN
read -p "Enter the required registry FQDN (default: $fqdn): " REGISTRY_FQDN
REGISTRY_FQDN=${REGISTRY_FQDN:-$fqdn}

# Prompt the user for registry username
read -p "Set registry username: " REGISTRY_USERNAME

# Prompt the user for registry password (silently)
read -s -p "Set registry password: " REGISTRY_PASSWORD
echo

rm -rf /var/lib/registry

# Create a directory to store the registry data
REGISTRY_DIR=/var/lib/registry
sudo mkdir -p $REGISTRY_DIR

# Generate a self-signed SSL certificate for the registry
sudo openssl req -newkey rsa:4096 -nodes -sha256 -keyout $REGISTRY_DIR/domain.key \
  -x509 -days 365 -out $REGISTRY_DIR/domain.crt \
  -subj "/C=US/ST=YourState/L=YourCity/O=YourOrganization/OU=YourUnit/CN=$REGISTRY_FQDN" \
  -addext "subjectAltName = DNS:$REGISTRY_FQDN"

# Create an authentication file for the registry
sudo docker run --rm --entrypoint htpasswd httpd:2 -Bbn $REGISTRY_USERNAME $REGISTRY_PASSWORD > $REGISTRY_DIR/htpasswd

# Start the Docker registry container with authentication
sudo docker run -d -p 5000:5000 --restart=always --name registry \
  -v $REGISTRY_DIR:/var/lib/registry \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/var/lib/registry/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/var/lib/registry/domain.key \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/var/lib/registry/htpasswd" \
  registry:2

# Output information
echo
echo
echo "Docker registry is now running with authentication and TLS."
echo "Registry URL: https://$REGISTRY_FQDN:5000"
echo "Username: $REGISTRY_USERNAME"
echo "Password: $REGISTRY_PASSWORD"
echo
echo


echo -e "\nDocker client configuration required. Ensure Docker is restarted for the changes to take effect."
echo "=============================================================================="

# Option 1: Disable SSL Verification
echo -e "\nOption 1: Disable SSL Verification"
echo "Create file daemon.json with the following content:"
echo "/etc/docker/daemon.json"
echo "{\n    \"insecure-registries\": [\"$REGISTRY_FQDN:5000\"]\n}"
echo "=============================================================================="

# Option 2: Trust the Self-Signed Certificate
echo -e "\nOption 2: Trust the Self-Signed Certificate"
echo "Copy domain.crt and update CA certificates:"
echo "sudo scp $REGISTRY_DIR/domain.crt user@your_node_ip:/tmp/domain.crt"
echo "sudo ssh user@your_node_ip \"sudo mv /tmp/domain.crt /usr/local/share/ca-certificates/; sudo update-ca-certificates\""
echo "=============================================================================="

# Restart Docker
echo -e "\nRestart Docker"
echo "sudo systemctl restart docker"
echo "=============================================================================="

# Option 3: Integrate with k3s Deployed Kubernetes
echo -e "\nOption 3: Integrate with k3s Deployed Kubernetes"
echo "Copy domain.crt to k3s TLS directory:"
echo "sudo mv /tmp/domain.crt /var/lib/rancher/k3s/server/tls/"
echo "Restart k3s service:"
echo "sudo systemctl restart k3s"

echo "Create registry secret for authorization:"
echo "kubectl create secret docker-registry myregistrykey \\
  --docker-server=$REGISTRY_FQDN:5000 \\
  --docker-username=$REGISTRY_USERNAME \\
  --docker-password=$REGISTRY_PASSWORD"

echo "Define the secret in a pod YAML (example):"
echo "apiVersion: v1"
echo "kind: Pod"
echo "metadata:"
echo "  name: mypod"
echo "spec:"
echo "  containers:"
echo "  - name: my-container"
echo "    image: $REGISTRY_FQDN:5000/myimage:latest"
echo "  imagePullSecrets:"
echo "  - name: myregistrykey"
echo "=============================================================================="

echo "Configuration completed. Ensure Docker is restarted for changes to take effect."
