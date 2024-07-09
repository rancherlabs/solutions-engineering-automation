# Outputs

output "rancher_url" {
  value = "https://${var.rancher_server_dns[0]}"
}
