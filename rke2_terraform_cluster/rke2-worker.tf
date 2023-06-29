resource "libvirt_volume" "rke2-worker" {
  count           = length(var.rke2_agent_ips)
  name            = "worker-${count.index}"
  base_volume_id  = libvirt_volume.os_image_ubuntu.id
  pool            = libvirt_pool.rke2_cluster_pool.name
  size            = var.agent_disk_size
  format          = "qcow2"
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "worker-init" {
  count          = length(var.rke2_agent_ips)
  name           = "worker-init-${count.index}.iso"
  user_data      = data.template_file.worker_user_data[count.index].rendered
  pool           = libvirt_pool.rke2_cluster_pool.name
}

data "template_file" "worker_user_data" {
    count = length(var.rke2_agent_ips)  
    template = file("${path.module}/template/cloud_init_worker.cfg")
    vars = {
    NODE_NAME      = "${lower(var.rke2_worker_name)}-${count.index}",    
    #RKE2_SERVER_COUNT            = length(var.rke2_server_ips),
    RKE2_SERVER_JOIN_IP          = element(var.rke2_server_ips, 0),
    RKE2_JOIN_TOKEN              = var.rke2_join_token,
    INSTALL_RKE2_RELEASE         = var.install_rke2_version,
    }
}

# Define KVM domain to create rker2 agent 
resource "libvirt_domain" "rke2-worker-qcow2" {
  count  = length(var.rke2_agent_ips)
  name   = "${var.rke2_worker_name}-${count.index + 1}"
  memory = var.agent_memory
  vcpu   = var.agent_vcpu

  cloudinit = libvirt_cloudinit_disk.worker-init[count.index].id

  network_interface {
    network_id = libvirt_network.kube_network.id
    hostname  = "${var.rke2_worker_name}-${count.index}"
    addresses = [var.rke2_agent_ips[count.index]]
    wait_for_lease = true
  }

console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.rke2-worker[count.index].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

}


output "rke2_worker_ips" {
   value = flatten(libvirt_domain.rke2-worker-qcow2.*.network_interface.0.addresses)
# show IP, run 'terraform refresh' if not populated
#  value = "${flatten("${libvirt_domain.ubuntu-qcow2.*.network_interface.0.addresses}")}"
}

