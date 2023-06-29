resource "libvirt_volume" "rke2-add-server" {
  count           = length(var.rke2_add_server_ips)
  name            = "master-${count.index + 1}"
  base_volume_id  = libvirt_volume.os_image_ubuntu.id
  pool            = libvirt_pool.rke2_cluster_pool.name
  size            = var.rke2_server_disk_size
  format          = "qcow2"
}


# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "add-server-init" {
  count          = length(var.rke2_add_server_ips)
  name           = "add-server-init-${count.index + 1}.iso"
  user_data      = data.template_file.add_server_user_data[count.index].rendered
  pool           = libvirt_pool.rke2_cluster_pool.name
}

data "template_file" "add_server_user_data" {
    count = length(var.rke2_add_server_ips)  
    template = file("${path.module}/template/cloud_init_add_server.cfg")
    vars = {
    NODE_NAME      = "${lower(var.rke2_server_name)}-${count.index + 1}",    
    RKE2_SERVER_COUNT            = length(var.rke2_add_server_ips),
    RKE2_SERVER_JOIN_IP          = element(var.rke2_server_ips, 0),
    RKE2_JOIN_TOKEN              = var.rke2_join_token,
    INSTALL_RKE2_RELEASE         = var.install_rke2_version,
    }
}

# Define KVM domain to create rker2 server
resource "libvirt_domain" "rke2-add-server-qcow2" {
  count  = length(var.rke2_add_server_ips)
  name   = "${var.rke2_server_name}-${count.index + 1}"
  memory = var.rke2_server_memory
  vcpu   = var.rke2_server_vcpu

  cloudinit = libvirt_cloudinit_disk.add-server-init[count.index].id

  network_interface {
    network_id = libvirt_network.kube_network.id
    hostname  = "${var.rke2_server_name}-${count.index + 1}"
    addresses = [var.rke2_add_server_ips[count.index]]
    wait_for_lease = true
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.rke2-add-server[count.index].id
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}


output "rke2_add_server_ips" {
   value = flatten(libvirt_domain.rke2-add-server-qcow2.*.network_interface.0.addresses)
# show IP, run 'terraform refresh' if not populated
#  value = "${flatten("${libvirt_domain.ubuntu-qcow2.*.network_interface.0.addresses}")}"
}

