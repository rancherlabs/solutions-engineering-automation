terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
    }
    local = {
      source  = "hashicorp/local"
    }
    rancher2 = {
      source  = "rancher/rancher2"
    }
    ssh = {
      source  = "loafoe/ssh"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = local_file.kube_config_server_yaml.filename
  }
}


# Rancher2 bootstrapping provider
provider "rancher2" {
  alias = "bootstrap"

  api_url  = "https://${var.rancher_server_dns[0]}"
  insecure = true
  # ca_certs  = data.kubernetes_secret.rancher_cert.data["ca.crt"]
  bootstrap = true
}
