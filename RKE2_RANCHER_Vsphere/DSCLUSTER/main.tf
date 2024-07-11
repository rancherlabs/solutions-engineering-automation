provider "rancher2" {
  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
  insecure   = var.rancher_insecure
}

resource "rancher2_cloud_credential" "rancher_vsphere_creds" {
  name        = "${var.prefix}-vsphere_creds"
  description = "add vsphere credentials to rancher"

  vsphere_credential_config {
    username = var.vsphere_username
    password = var.vsphere_password
    vcenter  = var.vcenter_server
  }
}


# Create vsphere machine config v2
resource "rancher2_machine_config_v2" "rke2-ds-master" {
  generate_name = "${var.prefix}-rke2-ds-master"
  
  depends_on = [ rancher2_cloud_credential.rancher_vsphere_creds ]

  vsphere_config {
    clone_from     = var.master_clone_from
    creation_type  = var.creation_type
    datacenter     = var.datacenter
    folder         = var.folder
    vcenter        = var.vcenter
    network        = var.network
    cpu_count      = var.master_cpu_count
    memory_size    = var.master_memory_size
  }
}

resource "rancher2_machine_config_v2" "rke2-ds-worker" {
  generate_name = "${var.prefix}-rke2-ds-worker"

  depends_on = [ rancher2_cloud_credential.rancher_vsphere_creds ]

  vsphere_config {
    clone_from     = var.worker_clone_from
    creation_type  = var.creation_type
    datacenter     = var.datacenter
    folder         = var.folder
    vcenter        = var.vcenter
    network        = var.network
    cpu_count      = var.worker_cpu_count
    memory_size    = var.worker_memory_size
  }
}



# Create a new rancher v2 Cluster with multiple machine pools
resource "rancher2_cluster_v2" "vsphere-rke2" {
  name = "${var.prefix}-rke2"
  kubernetes_version                  = var.kubernetes_version
  enable_network_policy               = var.enable_network_policy
  default_cluster_role_for_project_members = "user"
  rke_config {
    machine_pools {
      name = "controlplane-rke2-pool1"
      cloud_credential_secret_name = rancher2_cloud_credential.rancher_vsphere_creds.id
      control_plane_role = true
      etcd_role = true
      worker_role = false
      quantity = var.master_quantity
      drain_before_delete = true
      machine_config {
        kind = rancher2_machine_config_v2.rke2-ds-master.kind
        name = rancher2_machine_config_v2.rke2-ds-master.name
      }
    }

    machine_pools {
      name = "worker-rke2-pool2"
      cloud_credential_secret_name = rancher2_cloud_credential.rancher_vsphere_creds.id
      control_plane_role = false
      etcd_role = false
      worker_role = true
      quantity = var.worker_quantity
      drain_before_delete = true
      machine_config {
        kind = rancher2_machine_config_v2.rke2-ds-worker.kind
        name = rancher2_machine_config_v2.rke2-ds-worker.name
      }
    }

    machine_pools {
      name = "app-rke2-pool2"
      cloud_credential_secret_name = rancher2_cloud_credential.rancher_vsphere_creds.id
      control_plane_role = false
      etcd_role = false
      worker_role = true
      quantity = var.worker_quantity
      drain_before_delete = true
      machine_config {
        kind = rancher2_machine_config_v2.rke2-ds-worker.kind
        name = rancher2_machine_config_v2.rke2-ds-worker.name
      }
    }
  }
}