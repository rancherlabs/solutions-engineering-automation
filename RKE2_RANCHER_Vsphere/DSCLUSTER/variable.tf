variable "rancher_api_url" {
  description = "Rancher API URL"
  type        = string
}

variable "rancher_access_key" {
  description = "Rancher access key"
  type        = string
}

variable "rancher_secret_key" {
  description = "Rancher secret key"
  type        = string
  sensitive   = true
}

variable "rancher_insecure" {
  description = "Rancher insecure flag"
  type        = bool
  default     = true
}

variable "vsphere_username" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vcenter_server" {
  description = "vCenter server address"
  type        = string
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "quickstart"
}

variable "master_clone_from" {
  description = "Path to the template to clone from for master nodes"
  type        = string
}

variable "worker_clone_from" {
  description = "Path to the template to clone from for worker nodes"
  type        = string
}

variable "datacenter" {
  description = "Datacenter path"
  type        = string
}

variable "folder" {
  description = "VM folder path"
  type        = string
}

variable "vcenter" {
  description = "vCenter server address"
  type        = string
}

variable "network" {
  description = "Network names"
  type        = list(string)
}

variable "creation_type" {
  default = "template"
  type    = string
}

variable "master_cpu_count" {
  description = "Number of CPUs for master nodes"
  type        = number
}

variable "worker_cpu_count" {
  description = "Number of CPUs for worker nodes"
  type        = number
}

variable "master_memory_size" {
  description = "Memory size in MB for master nodes"
  type        = number
}

variable "worker_memory_size" {
  description = "Memory size in MB for worker nodes"
  type        = number
}


variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
}

variable "enable_network_policy" {
  description = "Enable network policy for the cluster"
  type        = bool
}

variable "master_quantity" {
  description = "Number of master nodes"
  type        = number
  default     = 2
}

variable "worker_quantity" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}