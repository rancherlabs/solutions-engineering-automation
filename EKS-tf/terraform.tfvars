# AWS region used for all resources
aws_region       = "us-east-1"

# AWS access key used to create EKS resources
aws_access_key   = "your-access-key"

# AWS secret key used to create EKS resources
aws_secret_key   = "your-secret-key"

# AWS session token used to create EKS resources
aws_session_token = ""  # Leave empty if not using session token

# EKS cluster version (format: 0.00)
cluster_version  = "1.24"

# Prefix added to names of all resources 
resource_prefix  = "quickstart"

# Minimum size for the EKS managed node group
min_size          = 1

# Maximum size for the EKS managed node group
max_size          = 3

# Desired size for the EKS managed node group
desired_size      = 2

# List of EC2 instance types for the EKS managed node group
instance_type     = "t3.small"  # You can change this default to your preferred instance type
