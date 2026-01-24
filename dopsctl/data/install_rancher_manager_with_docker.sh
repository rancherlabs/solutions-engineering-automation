#!/bin/bash
docker_rancher() {
echo "Installing Rancher Manager using Docker..."
curl -fsSL get.docker.com | bash
systemctl enable docker
docker run --privileged -d --restart=no -p 8080:80 -p 8443:443 -p 36443:6443 -v rancher:/var/lib/rancher  rancher/rancher



}
docker_rancher
