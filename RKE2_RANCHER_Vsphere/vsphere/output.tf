output "rancher_server_url" {
  value = module.rancher_common.rancher_url
}

output "vm_ip" {
  value = vsphere_virtual_machine.vm.guest_ip_addresses[0]
}