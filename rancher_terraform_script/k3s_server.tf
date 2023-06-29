# Create the Ubuntu cloud image volume
resource "libvirt_volume" "k3s-server" {
  count          = length(var.k3s_server_ips)
  name            = "k3s-server-${count.index}"
  base_volume_id  = libvirt_volume.ubuntu_image.id
  pool            = libvirt_pool.k3s_cluster_pools.name
  size            = var.vm_disk_size
  format          = "qcow2"
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "k3s_server-init" {
  count          = length(var.k3s_server_ips)
  name           = "k3s_server-init-${count.index}.iso"
  user_data      = data.template_file.k3s_server_data[count.index].rendered
  pool           = libvirt_pool.k3s_cluster_pools.name
}


data "template_file" "k3s_server_data" {
    count = length(var.k3s_server_ips)  
    template = file("${path.module}/cloud_init.cfg")
    vars = {
    NODE_NAME      = "${lower(var.k3s_server_name)}-${count.index}",
    K3s_SERVER_IP          = element(var.k3s_server_ips, 0),
    INSTALL_K3s_RELEASE  = var.install_k3s_version,
    RANCHER_VERSION      = var.rancher_version, 
    }
}


# Define KVM domain to create k3s server 
resource "libvirt_domain" "k3s-server-qcow2" {
  count  = length(var.k3s_server_ips)
  name   = "${var.k3s_server_name}-${count.index}"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.k3s_server-init[count.index].id

  network_interface {
    network_id = libvirt_network.k3s_network.id
    hostname  = "${var.k3s_server_name}-${count.index}"
    addresses = [var.k3s_server_ips[count.index]]
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
    volume_id = libvirt_volume.k3s-server[count.index].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "null_resource" "installk3sserver" {
  count = length(var.k3s_server_ips)
  
  connection {
      host      = element(flatten([libvirt_domain.k3s-server-qcow2.*.network_interface.0.addresses]), count.index)
      #host     = self.network_interface.0.addresses[0]
      type     = "ssh"
      user     = "root"
      password = "linux"
    }

  provisioner "file" {
    source      = "${path.module}/rancher_provisioner.sh"
    destination = "/tmp/rancher_provisioner.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
     "cloud-init status --wait > /dev/null 2>&1",
     "/tmp/k3s.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "bash -c 'wait_for_success \"/tmp/k3s.sh\" 5 5'",
      "chmod +x /tmp/rancher_provisioner.sh 2>&1",
      "bash /tmp/rancher_provisioner.sh  ${var.rancher_version} ${var.install_k3s_version}",
    ]
  }
}
  


output "k3s_server_ips" {
  value = flatten(libvirt_domain.k3s-server-qcow2.*.network_interface.0.addresses)
# show IP, run 'terraform refresh' if not populated
}
