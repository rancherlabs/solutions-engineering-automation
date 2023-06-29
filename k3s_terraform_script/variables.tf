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

variable "k3s_worker_ips" {
  description = "list of k3s worker ip's"
  type    = list(string)
  default = ["192.168.122.146"]
} 

variable "k3s_worker_name" {
  description = "The name of the k3s workers"
  default = "k3s-worker"
}

# Define the virtual machine resources
variable "vm_memory" {
  default = 2048
}

variable "vm_vcpu" {
  default = 2
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

variable "k3s_join_token"{
  description = "Token used to join cluster"                             
  default = "secrettoken"
}

variable "install_k3s_version" {
  description = "Select the k3s version"
  #https://github.com/k3s-io/k3s/tags
  default = "v1.25.11+k3s1"
}

