provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_route53_zone" "selected" {
  name         = var.aws_domain
  private_zone = false
}

data "template_file" "keycloak" {
  template = file("cloud-init.sh")
  vars = {
    keycloak_server_name   = "${var.instance_suffix}-keycloak.${var.aws_domain}"
    keycloak_password = var.keycloak_password
    docker_compose_version = var.docker_compose_version
    email                 = var.email
  }
}

resource "aws_instance" "keycloak" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name          = var.key_name

  associate_public_ip_address = true

  user_data = data.template_file.keycloak.rendered

  tags = {
    Name = "${var.instance_suffix}-keycloak"
  }
}

resource "aws_route53_record" "dns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.instance_suffix}-keycloak"
  type    = "A"
  ttl     = 300
  records = [aws_instance.keycloak.public_ip]
}

# check the keycloak server rediness and print the status

resource "null_resource" "keycloak_readiness_check" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash

      timeout=300  # Maximum time to wait in seconds
      interval=20  # Time to wait between checks in seconds
      end_time=$(( $(date +%s) + timeout ))

      while [ $(date +%s) -lt $end_time ]; do
        if curl -k -s -o /dev/null -w "%%{http_code}" -L https://${data.template_file.keycloak.vars.keycloak_server_name} | grep -q '^200$'; then
          echo "Keycloak is ready!"      
          exit 0
        fi
        echo "Keycloak not ready yet. Waiting $interval seconds..." 
        sleep $interval
      done

      echo "Timeout reached. Keycloak service is not ready."   
      exit 1
    EOT
  }

  depends_on = [aws_route53_record.dns]
}

output "keycloak_server_ip" {
    value = aws_instance.keycloak.public_ip
}

output "keycloak_server_name" {
    value = "https://${data.template_file.keycloak.vars.keycloak_server_name}"
}