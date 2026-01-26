variable "region" {
  description = "AWS region"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
}

variable "vpc_id" {
  description = "The VPC ID where the instance will be deployed"
}

variable "subnet_id" {
  description = "The Subnet ID where the instance will be deployed"
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
}

variable "ami_id" {
  description = "The AMI ID to use for the instance" 
}

variable "aws_domain" {
  description = "The domain name for the AWS Route 53"
}

variable "instance_suffix" {
  description = "Suffix to append to the instance name"
}

variable "keycloak_password" {
  description = "Keycloak admin password"
  type        = string
}

variable "email" {
  description = "email for cert verification"
  type = string
}

variable "docker_compose_version" {
  description = "docker-compose version" 
}