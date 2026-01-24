#!/bin/bash

# Prompt user for the URL
read -p "Enter the URL (e.g., abc.xyz.com): " URL

# Generate self-signed certificate using OpenSSL
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout tls.key -out tls.crt -subj "/CN=${URL}" -days 365

# Create Kubernetes Secret to store the certificate
kubectl create secret tls ${URL}-tls --cert=tls.crt --key=tls.key --namespace=cattle-system

# Create Ingress resource YAML
cat <<EOF > ingress-${URL}.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rancher-${URL}
  namespace: cattle-system
spec:
  ingressClassName: nginx
  rules:
  - host: ${URL}
    http:
      paths:
      - backend:
          service:
            name: rancher
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - ${URL}
    secretName: ${URL}-tls
EOF

# Apply the Ingress YAML file
kubectl apply -f ingress-${URL}.yaml

# Clean up temporary files
rm tls.crt tls.key ingress-${URL}.yaml
