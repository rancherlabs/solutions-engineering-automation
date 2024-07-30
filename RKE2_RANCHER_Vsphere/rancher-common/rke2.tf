# RKE2 cluster for Rancher

resource "ssh_resource" "install_rke2" {

  host        = "${var.node_public_ip}"
  user        = "${var.node_username}"
  password    = "${var.password}"
  #private_key  = var.private_key

  commands = [
    "curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_VERSION=${var.rancher_kubernetes_version} sh -",
    "sudo mkdir -p /etc/rancher/rke2",
    "echo 'token: mysecrettoken' | sudo tee -a /etc/rancher/rke2/config.yaml",
    "echo 'tls-san: ${var.node_public_ip}' | sudo tee -a /etc/rancher/rke2/config.yaml",
    "sudo systemctl enable --now rke2-server.service",
  ]
}

resource "ssh_resource" "retrieve_config" {
  depends_on = [
    ssh_resource.install_rke2
  ]
  host = var.node_public_ip
  commands = [
    "sudo sed \"s/127.0.0.1/${var.node_public_ip}/g\" /etc/rancher/rke2/rke2.yaml"
  ]
  user        = "${var.node_username}"
  password = "${var.password}"
  #private_key  = "${var.private_key}"
  
}
