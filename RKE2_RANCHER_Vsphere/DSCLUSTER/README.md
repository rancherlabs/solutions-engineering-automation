# This Terraform configuration creates a RKE2 cluster on vSphere. It includes cloud credential creation, machine configuration, and cluster setup with multiple machine pools.


## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed.
- Rancher server URL, access key, and secret key.
- vSphere credentials (username, password, and vCenter server details).

## Variables

The configuration uses the following variables:

`rancher_api_url`: The URL of the Rancher server.
`rancher_access_key`: The access key for the Rancher API.
`rancher_secret_key`: The secret key for the Rancher API.
`rancher_insecure`: Boolean to skip TLS verification.
`vsphere_username`: vSphere username.
`vsphere_password`: vSphere password.
`vcenter_server`: vCenter server URL.
`prefix`: Prefix for resource names.
`master_clone_from`: Template for master nodes.
`worker_clone_from`: Template for worker nodes.
`creation_type`: VM creation type.
`datacenter`: vSphere datacenter.
`folder`: vSphere folder.                # folder must be exist
`network`: vSphere network.
`master_cpu_count`: Number of CPUs for master nodes.
`master_memory_size`: Memory size for master nodes.
`worker_cpu_count`: Number of CPUs for worker nodes.
`worker_memory_size`: Memory size for worker nodes.
`kubernetes_version`: Kubernetes version.
`enable_network_policy`: Boolean to enable network policy.
`master_quantity`: Number of master nodes.
`worker_quantity`: Number of worker nodes.


## Usage

1. Clone this repository.
2. Create a `terraform.tfvars` file with the required variables.
3. Initialize Terraform:

~~~
terraform init
~~~

Apply the configuration:

~~~
terraform apply
~~~

## Important Notice
This deployment is intended for internal use only and is not suitable for production environments or customer deployments. It is provided as-is, without any warranties or guarantees. There is no official support provided by SUSE for this deployment.

## Additional Information
Feel free to customize the content further based on your specific project details and preferences.