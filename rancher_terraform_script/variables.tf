# Define the number of master and worker nodes
variable "k3s_server_ips" {
  description = "list of k3s server ip's"
  type    = list(string)
  default = ["192.168.122.145"]
} 

variable "k3s_server_name" {
  description = "The name of the k3s masters"
  default = "k3s-server"
}

# Define the virtual machine resources
variable "vm_memory" {
  default = 8096
}

variable "vm_vcpu" {
  default = 8
}

variable "vm_disk_size" {
  description = "Disk size (in Bytes) for nodes"
  default     = 1024 *1024 * 1024 * 10
}


################# common configuration #################
variable "ubuntu_image_path" {
  description = "Define the base Ubuntu image for the VMs"  
  default  = "./ubuntu-16.04-server-cloudimg-amd64-disk1.img"
  #default = "http://cloud-images.ubuntu.com/releases/23.04/release-20230420/ubuntu-23.04-server-cloudimg-amd64.img"

}

variable "k3s_cluster_pools" {
  description = "The directory where the pool will keep all its volumes"
  default = "/home/skanakal/Downloads/k3s_cluster_pools"
}

variable "install_k3s_version" {
  description = "Select the k3s version"
  #https://github.com/k3s-io/k3s/tags
  default = "v1.24.12+k3s1"
}

variable "rancher_version" {
  description = "Select the Rancher version"
  #https://github.com/rancher/rancher/tags
  default = "v2.7.3"
}


