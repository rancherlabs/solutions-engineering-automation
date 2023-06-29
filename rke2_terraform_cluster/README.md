# RKE2 Terraform Single node/HA cluster 

This repository contains Terraform scripts for deploying RKE2 single and HA clusters. It also includes cloud-init templates for configuring servers.

Prerequisites:
Before you can deploy the RKE2 cluster using Terraform, make sure you have the following prerequisites:
- Terraform
- Virtual Machine Manager
- [Ubuntu Server Cloud Image](https://cloud-images.ubuntu.com/)

# Repository Structure
The repository is organized as follows:

~~~
├── template/
│   ├── cloud_init_add_server.cfg
│   ├── cloud_init_server.cfg
│   └── cloud_init_worker.cfg
| 
├── main.tf
├── rke2-additional-server.tf
├── rke2-server.tf
├── rke2-worker.tf
├── terraform.tfvars
└── variable.tf
~~~

`template:` Contains cloud-init templates used for server configuration.

`main.tf:` Main Terraform configuration file.

`rke2-additional-server.tf:` Terraform configuration for adding an additional server to the cluster.

`rke2-server.tf:` Terraform configuration for the primary RKE2 server.

`rke2-worker.tf:` Terraform configuration for RKE2 worker nodes.

`terraform.tfvars:` Variables file for configuring the cluster.

`variable.tf:` Terraform variable definitions.

# Usage
To deploy the RKE2 cluster, follow these steps:

1. Clone this repository:

~~~
git clone  https://github.com/your-username/xxx.git
cd
~~~
2. Customize the deployment by modifying the `terraform.tfvars` file.
3. Initialize Terraform:
~~~
terraform init
~~~
4. Plan the Terraform deployment:
~~~
terraform plan
~~~
5. Deploy the RKE2 cluster:
~~~
terraform apply
~~~
Note: Confirm the deployment by typing `yes` when prompted.

When provisioning has finished, terraform will output the IP addresses of the RKE2 cluster to connect and you can find the `KUBECONFIG` at `/etc/rancher/rke2/rke2.yaml`. 

# Removing Resources
If you want to remove or tear down all the resources created by Terraform and delete the RKE2 cluster: run `terraform destroy -auto-approve`
