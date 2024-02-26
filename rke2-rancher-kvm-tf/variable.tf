####### RKE2 controlplane configuration ###########
variable "rke2_server_ips" {
  description = "list of rke2 server ip's"
  type    = list(string)
  default = ["192.168.100.151"]
} 

variable "rke2_server_memory" {
  description = "Memory (in MiB) for rke2 controlplane"
  default     = 4096
}

variable "rke2_server_vcpu" {
  description = "Number of vCPUs for rke2 controlplane"
  default     = 4
}

variable "rke2_server_disk_size" {
  description = "Disk size (in Bytes) for rke2 controlplane"
  default     = 1024 *1024 * 1024 * 25
}

variable "rke2_server_name" {
  description = "The name of the rke2 masters"
  default = "master"
}

######### Default Configuration for RKE2 cluster nodes ############

variable "rke2_os_image_path" {
  description = "Path to the operating system image"
  #default  = "./ubuntu-16.04-server-cloudimg-amd64-disk1.img"
  default = "http://cloud-images.ubuntu.com/releases/23.04/release-20230420/ubuntu-23.04-server-cloudimg-amd64.img"

}

variable "rke2_cluster_storage_pool_path" {
  description = "The directory where the pool will keep all its volumes"
  default = "/home/skanakal/Downloads/rke2_cluster_storage"
}

variable "rke2_join_token"{
  description = "Token used to join cluster"                             
  default = "secrettoken"
}

variable "install_rke2_version" {
  description = "Select the rke2 version"
  #https://github.com/rancher/rke2/tags
  default = "v1.24.14+rke2r1"
}

variable "rancher_version" {
  description = "select the rancher version"
  default = "2.7.3"
}
