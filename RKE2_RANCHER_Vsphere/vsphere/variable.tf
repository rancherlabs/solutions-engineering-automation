variable "vsphere_env" {
  description = "Variables for vSphere environment"
  type = object({
    datacenter         = string         # Name of the vSphere datacenter
    datastore          = string         # Name of the vSphere datastore
    compute_cluster    = string         # Name of the vSphere compute cluster
    vm_network         = string         # Name of the vSphere network
    template           = string         # Name of the vSphere VM template
    folder             = string         # The name of the folder where the VM will be placed
    server             = string         # The address of the vSphere server
    user               = string         # The username for authenticating with the vSphere server
    password           = string         # The password for authenticating with the vSphere server
    allow_unverified_ssl = bool         # Whether to allow unverified SSL certificates (useful for self-signed certs)
    num_cpus             = number       # The number of CPUs for the VM
    memory               = number       # The amount of memory (in MB) for the VM
    ipv4_gateway          = string      # The IPv4 gateway for the VM
    dns_suffix_list       = list(string)  # The DNS suffix list for the VM
    dns_server_list       = list(string)  # The DNS server list for the VM
  })
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "quickstart"
}

# Required
variable "node_username" {
  type        = string
  description = "Username used for SSH access to the Rancher server cluster node"
  default = "root"
}

# Required
variable "password" {
    type = string
    description = "default password for SSH"
}

# Required
# variable "private_key" {
#   type        = string
#   description = "Private key used for SSH access to the Rancher server cluster node"
# }

variable "rancher_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for Rancher server cluster"
  default     = "v1.24.17+rke2r1"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
  default     = "1.11.0"
}

variable "rancher_version" {
  type        = string
  description = "Rancher server version (format v0.0.0)"
  default     = "2.7.9"
}


# Required
variable "admin_password" {
  type        = string
  description = "Admin password to use for Rancher server bootstrap, min. 12 characters"
}

variable "rancher_helm_repository" {
  type        = string
  description = "The helm repository, where the Rancher helm chart is installed from"
  default     = "https://releases.rancher.com/server-charts/latest"
}
