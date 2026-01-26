# terraform.tfvars

# AWS region to deploy the instance
region = ""       # Select your region

# AWS credentials
aws_access_key = ""  # Replace with your AWS Access Key
aws_secret_key = ""  # Replace with your AWS Secret Key

# EC2 instance type
instance_type = ""       # Choose your instance type

# Name of the SSH key pair to use for the EC2 instance
key_name = ""  # Replace with your actual key pair name

# VPC ID where the EC2 instance will be deployed
vpc_id = ""  # Replace with your actual VPC ID

# Subnet ID within the VPC where the EC2 instance will be deployed
subnet_id = ""  # Replace with your actual Subnet ID

# Security Group IDs associated with the EC2 instance
security_group_ids = [""]  # Replace with your actual Security Group IDs

# AMI ID for the EC2 instance
ami_id = ""   # Use any Ubuntu image, as the `cloud-init.sh` script is compatible only with Ubuntu images

# AWS Route 53 domain name
aws_domain = ""  # Update your AWS domain

# Suffix to append to the instance name and DNS record
instance_suffix = ""  # e.g., 'dev', 'prod', or any other environment identifier

# Keycloak admin password
keycloak_password = ""  # Replace with a secure password

#Email needs to be valid, otherwise certbot will fail
email = ""

# docker compose version, note: I've tested with older versions 
docker_compose_version = ""