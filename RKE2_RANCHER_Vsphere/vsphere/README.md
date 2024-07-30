# RKE2 RANCHER cluster on vsphere with Terraform
This project automates the deployment of an RKE2 on vsphere using Terraform, with Rancher installed for Kubernetes management.

The structure of this project, including Terraform modules and configuration, is adapted from the Rancher Quickstart.

The created VM will be accessible over SSH using the `root` user and password `of-your-choice`(make sure you send this info thru userdata.yml) or you can use `private_key`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.5.1 |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [vsphere](#provider\_vsphere) | 2.8.2 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |
| <a name="provider_rancher2"></a> [rancher2](#provider\_rancher2) | 4.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rancher_common"></a> [rancher\_common](#module\_rancher\_common) | ../rancher-common | n/a |

## Example Configuration
Here is an example of how to set your variables:

~~~
vsphere_env = {
  datacenter           = "Datacenter"
  datastore            = "Datastore"
  compute_cluster      = "Cluster"
  vm_network           = "VM Network"
  template             = "Template"
  folder               = "vm-folder" # Folder must exist
  server               = "vsphere-server"
  user                 = "root"
  password             = "helloworld!"
  allow_unverified_ssl = true
  num_cpus             = 4
  memory               = 8192
  # ipv4_gateway         = "10.0.0.1"
  # dns_suffix_list      = ["example.com"]
  # dns_server_list      = ["8.8.8.8", "8.8.4.4"]
}

prefix = "my-cluster"

node_username                = "root"
password                     = "linux"
# private_key                  = "path/to/private/key"
rancher_kubernetes_version   = "v1.24.17+rke2r1"
cert_manager_version         = "1.11.0"
rancher_version              = "2.7.9"
admin_password               = "rancherpassword1234"
rancher_helm_repository      = "https://releases.rancher.com/server-charts/latest"
~~~

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rancher_node_ip"></a> [rancher\_node\_ip](#output\_rancher\_node\_ip) | n/a |
| <a name="output_rancher_server_url"></a> [rancher\_server\_url](#output\_rancher\_server\_url) | n/a |

## Important Notice

This deployment is intended for internal use only and is not suitable for production environments or customer deployments. It is provided as-is, without any warranties or guarantees. There is no official support provided by SUSE for this deployment.

## Additional Information

Feel free to customize the content further based on your specific project details and preferences.
