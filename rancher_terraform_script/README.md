# Terraform Script for Creating a Rancher on KVM

This repository contains a Terraform script that allows you to easily create a Rancher server on a KVM (Kernel-based Virtual Machine) hypervisor. The script automates the provisioning process, enabling you to quickly set up a Rancher server environment for managing your containerized applications.

# Prerequisites
Before using this Terraform script, make sure you have the following:

1. KVM Hypervisor: Ensure that you have a working KVM hypervisor environment set up. You can refer to the KVM documentation for installation instructions specific to your operating system.
2. Terraform: Install Terraform on your local machine. Visit the official Terraform website for installation instructions.
3. [Ubuntu Server Cloud Image](https://cloud-images.ubuntu.com/)

# Usage
To use this Terraform script, follow these steps:

1. Clone this repository to your local machine:

~~~
git clone https://github.com/your-username/rancher-terraform-cluster.git
~~~

2. Navigate to the cloned repository:

~~~
cd rancher-terraform-cluster
~~~

3. Modify the `terraform.tfvars` file with your desired configuration options. You can specify parameters such as the VM size, network settings, and Rancher version.

4. Initialize the Terraform working directory:

~~~
terraform init
~~~

5. Review the execution plan:

~~~
terraform plan
~~~

This step will display the resources that will be created and any changes that will be made.

6. Deploy the Rancher server:

~~~
terraform apply
~~~

Confirm the deployment by entering "yes" when prompted.

7. Terraform will start creating the necessary resources, including a VM instance with the specified configuration.

8. Once the deployment is complete, terraform will output the IP addresses of the k3s cluster and rancher server URL and password.

# Configuration

The `terraform.tfvars` file contains variables that can be customized to suit your requirements. Update the following variables to match your environment:

* `k3s_server_ips:` The IP address of the k3s server
* `vm_vcpu & vm_memory:` The size (CPU and RAM) of the VM instance.
* `vm_disk_size:` The size of the VM's disk in gigabytes.
* `install_k3s_version:` The desired version of k3s to be installed. 
* `rancher_version:` The desired version of Rancher to be installed.

Feel free to modify any other variables in the script to match your specific needs.

# Cleanup

To remove the Rancher server and associated resources created by this Terraform script, run the following command:

~~~
terraform destroy
~~~

Confirm the destruction by entering "yes" when prompted.
