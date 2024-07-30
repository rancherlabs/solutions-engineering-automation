# Variables for rancher common module

# Required
variable "node_public_ip" {
  description = "Public IP of compute node for Rancher cluster"
}

# Required
variable "node_username" {
  type        = string
  description = "Username used for SSH access to the Rancher server cluster node"
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

variable "password" {
  type = string
  description = "default password for SSH"
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

#Required
variable "rancher_server_dns" {
  type        = list(string)
  description = "DNS host name of the Rancher server"
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