# RKE2 cluster for Rancher

resource "ssh_resource" "install_rke2" {
  count = length(var.node_public_ip) > 0 ? 1 : 0

  host        = var.node_public_ip[0]
  user        = var.node_username
  private_key = var.ssh_private_key_pem

  commands = [
    "curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_VERSION=${var.rancher_kubernetes_version} sh -",
    "sudo mkdir -p /etc/rancher/rke2",
    "echo 'token: mysecrettoken' | sudo tee -a /etc/rancher/rke2/config.yaml",
    "echo 'tls-san: ${var.node_public_ip[0]}' | sudo tee -a /etc/rancher/rke2/config.yaml",
    "sudo systemctl enable --now rke2-server.service",
  ]
}

resource "ssh_resource" "retrieve_config" {
  depends_on = [
    ssh_resource.install_rke2
  ]
  host = var.node_public_ip[0]
  commands = [
    "sudo sed \"s/127.0.0.1/${var.node_public_ip[0]}/g\" /etc/rancher/rke2/rke2.yaml"
  ]
  user        = var.node_username
  private_key = var.ssh_private_key_pem
}

# join additional nodes to RKE2 cluster 

resource "ssh_resource" "install_add_rke2" {
  depends_on = [
    ssh_resource.install_rke2
  ]
  count = length(var.node_public_ip) > 1 ? length(var.node_public_ip) - 1 : 0

  host        = element(var.node_public_ip, count.index + 1)
  user        = var.node_username
  private_key = var.ssh_private_key_pem

  commands = [
    "curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_VERSION=${var.rancher_kubernetes_version} sh -",
    "sudo mkdir -p /etc/rancher/rke2",
    "echo 'server: https://${var.node_public_ip[0]}:9345' | sudo tee -a /etc/rancher/rke2/config.yaml",
    "echo 'token: mysecrettoken' | sudo tee -a /etc/rancher/rke2/config.yaml",
    "echo 'tls-san: ${var.node_public_ip[0]}' | sudo tee -a /etc/rancher/rke2/config.yaml",
    "sudo systemctl enable --now rke2-server.service",
  ]
}
