vsphere_env = {
  datacenter           = ""
  datastore            = ""
  compute_cluster      = ""
  vm_network           = ""
  template             = ""
  folder               = ""                                 # folder must be exist
  server               = ""
  user                 = ""
  password             = ""
  allow_unverified_ssl = true
  num_cpus             = ""
  memory               = ""
  # ipv4_gateway         = ""
  # dns_suffix_list      = [""]
  # dns_server_list      = [""]
}

# Prefix added to names of all resources
prefix = ""



node_username                = "root"
password                     = "linux"
#private_key                  = ""
rancher_kubernetes_version   = "v1.24.17+rke2r1"
cert_manager_version         = "1.11.0"
rancher_version              = "2.7.9"
admin_password               = "rancherpassword1234"
rancher_helm_repository      = "https://releases.rancher.com/server-charts/latest"