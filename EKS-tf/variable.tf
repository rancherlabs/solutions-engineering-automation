variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Required
variable "aws_access_key" {
  type        = string
  description = "AWS access key used to create EKS cluster"
}

# Required
variable "aws_secret_key" {
  type        = string
  description = "AWS secret key used to create EKS cluster"
}

variable "aws_session_token" {
  type        = string
  description = "AWS session token used to create EKS cluster"
  default     = ""
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "1.24"
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "quickstart"
}

variable "min_size" {
  description = "Minimum size for the EKS managed node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size for the EKS managed node group"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Desired size for the EKS managed node group"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "List of EC2 instance types for the EKS managed node group"
  type        = string
  default     = null  # You can change this default to your preferred instance type
}