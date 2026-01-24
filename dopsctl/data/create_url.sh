#!/bin/bash

# Prompt user for the URL
read -p "Enter the URL (e.g., abc.xyz.com): " URL

# Create Certificate resource YAML
cat <<EOF > cert.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${URL}-certificate
  namespace: cattle-system
spec:
  secretName: ${URL}-tls
  dnsNames:
    - ${URL}
  issuerRef:
    name: rancher
    kind: Issuer
  usages:
    - digital signature
    - key encipherment
EOF

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

# Apply the YAML files
kubectl apply -f cert.yaml
kubectl apply -f ingress-${URL}.yaml

# Clean up temporary files
rm cert.yaml ingress-${URL}.yaml
