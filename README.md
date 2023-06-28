# k3s Cluster Creation Terraform Script

This Terraform script automates the creation of a k3s cluster, simplifying the deployment process. By using this script, you can quickly provision a k3s cluster on your local machine.

Prerequisites: Before you can deploy the k3s cluster using Terraform, make sure you have the following prerequisites:

Terraform
Virtual Machine Manager
Ubuntu Server Cloud Image

# Usage
To deploy the k3s cluster, follow these steps:

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
5. Deploy the k3s cluster:
~~~
terraform apply
~~~
Note: Confirm the deployment by typing `yes` when prompted.

When provisioning has finished, terraform will output the IP addresses of the k3s cluster to connect and you can find the `KUBECONFIG` at `/etc/rancher/k3s/k3s.yaml`. 

# Removing Resources
If you want to remove or tear down all the resources created by Terraform and delete the k3s cluster: run `terraform destroy -auto-approve`