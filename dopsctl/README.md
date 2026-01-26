# Dopsctl
A comprehensive tool for swiftly deploying Rancher products (RKE, RKE2, K3s, Rancher), while also managing DevOps operations like DNS servers, proxy servers, local image registries, and more.


## Description

A comprehensive tool for swiftly deploying Rancher products (RKE, RKE2, K3s, Rancher), while also managing DevOps operations like DNS servers, proxy servers, local image registries, and more. It utilizes the GitHub API to fetch and deploy the latest or selected releases, while offering advanced features such as cluster data retrieval for health verification and a menu-driven command-line utility for TCP dump packet capture.

## Goals

The goal of the project is to simplify the deployment of required products and enable easy replication of environments with exact product versions. Assist engineers in efficiently troubleshooting live Kubernetes environments.

## Features

**Quick Deployment:** Simplifies the deployment of Rancher products (RKE, RKE2, K3s, Rancher) and supporting tools like Helm and kubectl on Ubuntu OS.

**Version Fetching:** Utilizes the GitHub API to fetch and deploy the latest or selected releases.

**Menu-Driven Interface:** Provides an intuitive, menu-driven CLI for easy installation and configuration.

**Architecture Detection:** Automatically detects system architecture (AMD or ARM) and deploys compatible products.

**Installation Validation:** Ensures the successful completion of installations with built-in checks.

**Live Environment Troubleshooting:** Facilitates troubleshooting by analyzing cluster health, fetching logs for specific time windows, and understanding network status using a TCP dump utility.

**Future Enhancements:** Plans to introduce more options and extend features for greater flexibility.


## Installation

1. Clone this repository to your local machine:

```
git clone https://github.com/khushalchandak17/dopsctl.git 
```

2. Change to the project directory and make the scripts executable:

```
cd dopsctl
chmod +x ./*
```

## Usage

1. Start the script:

```
./dopsctl.sh
```

2. After executing the script, you will see the following menu:

```
Please select an option for Installations:
A. Install Kubernetes
   1. Install rke
   2. Install rke2
   3. Install k3s
   4. Install k8s
B. Install Rancher
   5. Install Rancher via Helm
   6. Install Rancher via Docker
C. Container Runtime
   7. Install Docker
   8. Install containerd
   9. Install crio
   10. Install podman
D. Utility
   11. Install kubectl
   12. Install Helm
E. Services
   13. Deploy DNS Server
   14. Deploy Proxy
F. Deploy
   15. Deploy Private Image Registry
   16. Deploy LB via HAproxy
   17. Deploy LB via Nginx
   18. Deploy LB via Traefik
   99. Deploy Sample Webserver
...
.....
......
```

3. Choose the desired installation option by entering the corresponding number.

 1.   Follow the prompts and provide the necessary arguments.

 2.   Wait for the script to complete the deployment.

 3.   Verify the successful installation.

## Requirements

  - Git
  - Bash

## Contributing

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please create an issue or submit a pull request.

