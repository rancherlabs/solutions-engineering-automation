# Terraform Virtual Machine with RKE2 and Rancher

This Terraform script automates the process of creating a Virtual Machine (VM) on your laptop using KVM (Kernel-based Virtual Machine) and sets up RKE2 (Rancher Kubernetes Engine 2) and Rancher on it. With this, you can quickly deploy a RKE2 cluster and manage it using Rancher.

# Prerequisites
Before using this Terraform script, make sure you have the following:

1. KVM Hypervisor: Ensure that you have a working KVM hypervisor environment set up. You can refer to the KVM documentation for installation instructions specific to your operating system.
2. Terraform: Install Terraform on your local machine. Visit the official Terraform website for installation instructions.
3. [Ubuntu Server Cloud Image](https://cloud-images.ubuntu.com/)

# Usage
To use this Terraform script, follow these steps:

1. Clone this repository to your local machine:

~~~
git clone https://github.com/your-username/rke2-rancher-kvm-tf.git
~~~

2. Navigate to the cloned repository:

~~~
cd rke2-rancher-kvm-tf
~~~

3. Modify the `terraform.tfvars` file with your desired configuration options. You can specify parameters such as the VM size, network settings, and RKE2, Rancher versions.

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

8. Once the deployment is complete, terraform will output the IP addresses of the RKE2 cluster nodes and rancher server URL and password.

# Configuration

The `terraform.tfvars` file contains variables that can be customized to suit your requirements. Update the following variables to match your environment:

* `rke2_server_ips & rke2_agent_ips:` The IP address of the rke2 server and agent
* `rke2_server_vcpu & agent_vcpu:` CPU of the rke2 server and agent node.
* `rke2_server_memory & agent_memory:` Memory of the server and agent.
* `rke2_server_disk_size & agent_disk_size:` The size of the VM's disk in gigabytes.
* `install_rke2_version:` The desired version of RKE2 to be installed. 
* `rancher_version:` The desired version of Rancher to be installed.

Feel free to modify any other variables in the script to match your specific needs.

# Cleanup

To remove the Rancher server and associated resources created by this Terraform script, run the following command:

~~~
terraform destroy
~~~

Confirm the destruction by entering "yes" when prompted.
