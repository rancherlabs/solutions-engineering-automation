# Keycloak Server Automation with Terraform

Terraform configurations for automating the deployment of a Keycloak server on AWS. The deployment script provisions an EC2 instance with Keycloak installed and configured, using specified AWS resources and settings.

## Prerequisites

Before you begin, ensure you have the following:

- **Terraform**: Make sure Terraform is installed on your local machine. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).


## Configuration

1. Clone the Repository

   ```
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Update `terraform.tfvars`
   
   Edit the terraform.tfvars file with your specific AWS and Keycloak configurations:
   
4. Initialize Terraform
   
   Run the following command to initialize Terraform. This will download the necessary provider plugins:

   ```
   terraform init
   ```
6. Plan the Deployment
   
   Create an execution plan to review the resources that Terraform will create or modify:
   ```
   terraform plan
   ```
7. Apply the Configuration

   Apply the Terraform configuration to create the resources:
   ```
   terraform apply
   ```
   Confirm the action by typing `yes` when prompted.

## Keycloak Access
Once the deployment is complete, you can access your Keycloak server using the provided domain. 
~~~
Admin URL: https://prefix-keycloak.test.rancher.space
Admin Username: admin
Admin Password: The password specified in `terraform.tfvars`.
~~~

Cleanup:

To remove the resources created by Terraform, run:  
```
terraform destroy
```
Confirm the action by typing `yes` when prompted.

# Important Notice

This deployment is intended for internal use only and is not suitable for production environments or customer deployments. It is provided as-is, without any warranties or guarantees. There is no official support provided by SUSE for this deployment.

# Additional Information

Feel free to customize the content further based on your specific project details and preferences.