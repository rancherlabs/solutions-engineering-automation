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
    null  = {
      source = "hashicorp/null"
      version = "~> 3.2.1"
    }
  }
}

provider "libvirt" {
  # Configuration options
  uri = "qemu:///system"
}

# Base pool for all cluster volumes
resource "libvirt_pool" "k3s_cluster_pools" {
  name = "k3s_cluster_pools"
  type = "dir"
  path = var.k3s_cluster_pools
}

# Base OS image to use to create a cluster of different nodes
resource "libvirt_volume" "ubuntu_image" {
  name   = "ubuntu_image"
  pool   = libvirt_pool.k3s_cluster_pools.name
  source = var.ubuntu_image_path
  format = "qcow2"
}

resource "libvirt_network" "k3s_network" {
   name = "kube_network"
   mode = "nat"
   addresses = ["192.168.122.0/24"]
   autostart = true
   dhcp {
      enabled = false
   }
   dns {
     enabled = true
   }
}
