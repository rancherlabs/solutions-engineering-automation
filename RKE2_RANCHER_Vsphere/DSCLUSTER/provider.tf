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