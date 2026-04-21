#!/bin/bash
apt update -y
apt install docker* -y
systemctl enable --now docker.service
apt install certbot -y
apt install docker-compose -y


# Request Certificate. 
certbot certonly --non-interactive --standalone -d ${keycloak_server_name} --agree-tos -m ${email}

# Set up Keycloak certificates directory
mkdir -p /opt/keycloak/certs
cp /etc/letsencrypt/live/${keycloak_server_name}/fullchain.pem /opt/keycloak/certs
cp /etc/letsencrypt/live/${keycloak_server_name}/privkey.pem /opt/keycloak/certs
chmod 755 /opt/keycloak/certs
chmod 644 /opt/keycloak/certs/*


cat <<EOF > /opt/keycloak/keycloak.yml
version: '3'
services:
  keycloak:
    image: quay.io/keycloak/keycloak:latest
    container_name: keycloak
    restart: always
    ports:
      - 80:8080
      - 443:8443
    volumes:
      - ./certs/fullchain.pem:/etc/x509/https/tls.crt
      - ./certs/privkey.pem:/etc/x509/https/tls.key
    environment:
      - KEYCLOAK_ADMIN=admin
      - KEYCLOAK_ADMIN_PASSWORD=${keycloak_password}
      - KC_HOSTNAME=${keycloak_server_name}
      - KC_HTTPS_CERTIFICATE_FILE=/etc/x509/https/tls.crt
      - KC_HTTPS_CERTIFICATE_KEY_FILE=/etc/x509/https/tls.key
    command:
      - start-dev
EOF

# Start Keycloak with Docker Compose
cd /opt/keycloak
docker-compose -f /opt/keycloak/keycloak.yml up
