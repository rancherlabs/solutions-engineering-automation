# Define the vSphere provider
provider "vsphere" {
  user                 = var.vsphere_env.user
  password             = var.vsphere_env.password
  vsphere_server       = var.vsphere_env.server
  allow_unverified_ssl = var.vsphere_env.allow_unverified_ssl
}

# Define data sources for the vSphere resources
data "vsphere_datacenter" "dc" {
  name = var.vsphere_env.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_env.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_env.compute_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_env.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_env.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_folder" "vm_folder" {
  path          = var.vsphere_env.folder
  #The absolute path of the folder. For example, given a default datacenter of default-dc, a folder of type vm, and a folder name of terraform-test-folder, 
  #the resulting path would be /default-dc/vm/terraform-test-folder
}

# Define the VM resource
resource "vsphere_virtual_machine" "vm" {
  name             = "${var.prefix}-rancher-server"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  
  firmware = data.vsphere_virtual_machine.template.firmware
  num_cpus = var.vsphere_env.num_cpus
  memory   = var.vsphere_env.memory
  guest_id = data.vsphere_virtual_machine.template.guest_id

  folder =  var.vsphere_env.folder

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "${var.prefix}-disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = false
    thin_provisioned = true
    unit_number      = 0
    
  }
  disk {
    label            = "${var.prefix}-disk1"
    size             = data.vsphere_virtual_machine.template.disks[1].size
    eagerly_scrub    = false
    thin_provisioned = true
    unit_number      = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    # customize {
    #   linux_options {
    #     host_name = "${var.prefix}-rancher-server"
    #     domain    = "local"
    #   }

    #  }
  }
  extra_config = {
  "guestinfo.userdata"          = base64encode(file("${path.module}/userdata.yml"))
  "guestinfo.userdata.encoding" = "base64"
  }
}


module "rancher_common" {
  source = "../rancher-common"
  
  node_public_ip             = "${vsphere_virtual_machine.vm.guest_ip_addresses[0]}"
  node_username              = "${var.node_username}"
  #private_key                = "${var.private_key}"
  password                   = "${var.password}"
  rancher_kubernetes_version = "${var.rancher_kubernetes_version}"
  cert_manager_version    = "${var.cert_manager_version}"
  rancher_version         = "${var.rancher_version}"
  rancher_helm_repository = "${var.rancher_helm_repository}"

  rancher_server_dns = [
    join(".", ["rancher", "${vsphere_virtual_machine.vm.guest_ip_addresses[0]}", "sslip.io"]),
  ]

  admin_password = "${var.admin_password}"

}
