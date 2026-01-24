#!/bin/bash


# Check if packages are installed
packages=("docker.io" "docker-doc" "docker-compose" "docker-compose-v2" "podman-docker" "containerd" "runc")
missing_packages=()

for pkg in "${packages[@]}"; do
  if ! dpkg -l | grep -q $pkg; then
    missing_packages+=("$pkg")
  fi
done

if [ ${#missing_packages[@]} -eq 0 ]; then
  echo "All required packages are installed."
else
  echo "The following packages are not installed: ${missing_packages[@]}"
  read -p "Do you want to continue with the removal of installed packages? (y/n): " CONTINUE_REMOVAL
  if [ "$CONTINUE_REMOVAL" != "y" ]; then
    echo "Removal canceled. Exiting."
    exit 0
  fi
fi

# Perform package removal
for pkg in "${packages[@]}"; do
  sudo apt-get remove -y $pkg
done

echo "Package removal completed."





# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update




# List the available Docker versions:
clear
echo "Available Docker Versions:"
versions=($(apt-cache madison docker-ce | awk '{ print $3 }'))
for i in "${!versions[@]}"; do
  echo "$((i+1)). ${versions[i]}"
done

# Prompt user for Docker version selection:
read -p "Enter the number corresponding to the desired Docker version (or 'latest' for the latest version): " VERSION_INDEX

# Install Docker based on user input:
if [ "$VERSION_INDEX" = "latest" ]; then
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  SELECTED_VERSION="${versions[$((VERSION_INDEX-1))]}"
  sudo apt-get install -y docker-ce="$SELECTED_VERSION" docker-ce-cli="$SELECTED_VERSION" containerd.io docker-buildx-plugin docker-compose-plugin
fi
