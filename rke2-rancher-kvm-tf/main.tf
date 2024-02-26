# Required providers
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~>3.5.1"
    }
    template = {
      source = "hashicorp/template"
      version = "~>2.2.0"
    }
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "~> 0.7.1"
    }
  }
}

provider "libvirt" {
  # Configuration options
  uri = "qemu:///system"
}


# A pool for all cluster volumes
resource "libvirt_pool" "rke2_cluster_pool" {
  name = "rke2_cluster_pool"
  type = "dir"
  path = var.rke2_cluster_storage_pool_path
}

# Base OS image to use to create a cluster of different nodes
resource "libvirt_volume" "os_image_ubuntu" {
  name   = "os_image_ubuntu"
  pool   = libvirt_pool.rke2_cluster_pool.name
  source = var.rke2_os_image_path
  format = "qcow2"
}

resource "libvirt_network" "kube_network" {
   name = "k8s_network"
   mode = "nat"
   addresses = ["192.168.100.0/24"]
   autostart = true
   dhcp {
      enabled = true
   }
   dns {
     enabled = true
   }
}
