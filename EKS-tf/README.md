# Create AWS EKS Cluster with Terraform

<p align="center">
  <img src="https://img.shields.io/badge/Terraform-v0.15+-blueviolet" alt="Terraform Version">
  <img src="https://img.shields.io/badge/AWS-EKS-orange" alt="AWS EKS">
</p>

## Overview

This Terraform project automates the setup of an AWS EKS (Elastic Kubernetes Service) cluster, including VPC infrastructure and managed node groups.

## Prerequisites

Ensure you have the following prerequisites:

- [Terraform](https://www.terraform.io/) (v0.15 or later) installed locally.
- AWS credentials configured with appropriate permissions.

## Project Structure

- `eks.tf`: Main Terraform configuration.
- `variables.tf`: Variable definitions.
- `provider.tf`: Provider configurations.
- `terraform.tfvars`: Variable values (customize as needed).
- `output.tf`: retrives useful info.
- `README.md`: Project documentation.

## Usage

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/rancherlabs/solutions-engineering-automation.git
   cd EKS-tf

2. **Initialize Terraform:**

    ```bash
    terraform init
3. **Review and Customize:**
   
   Review and customize the terraform.tfvars file with your specific values.

4. **Apply Terraform Configuration:**

   ```bash
   terraform apply
   
   Confirm with yes when prompted.

5. **Outputs**:

    Run the following command to retrieve the access credentials for your cluster and configure kubectl.

    ```bash
    $ aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
   
    Now the `kubeconfig` added to /home/$<username>/.kube/config, you can access the cluster
    
    $ kubectl get nodes
    
  
6. **Destroy Resources (when needed):**
   
   ```bash
   terraform destroy
   
**Configuration**:

   **Variables**:
 
 
  - `resource_prefix`: Prefix for resource names.
  - `cluster_version`: Version of the EKS cluster.
  - `min_size, max_size, desired_size`: Node group sizes.
  - `instance_types`: List of EC2 instance types for the node group.

   **AWS Availability Zones**
 
  The project utilizes the first three AWS Availability Zones in the specified region to distribute resources.

**Customization**

Feel free to customize configuration files to suit your specific requirements.
