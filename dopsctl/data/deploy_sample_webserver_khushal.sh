#!/bin/bash

# Define the YAML content
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: khushal
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gowebserver
  namespace: khushal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gowebserver
  template:
    metadata:
      labels:
        app: gowebserver
    spec:
      containers:
      - name: gowebserver
        image: docker.io/khushalchandak/do-go-web:latest
        ports:
        - containerPort: 8080   # Container port
---
apiVersion: v1
kind: Service
metadata:
  name: gowebserver-service
  namespace: khushal
spec:
  type: NodePort
  ports:
  - port: 8082   # Service port
    targetPort: 8080   # Target port (container port)
    nodePort: 30000   # Choose a port within the range 30000-32767
  selector:
    app: gowebserver
EOF
