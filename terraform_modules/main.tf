# ============================================================================
# ROOT TERRAFORM CONFIGURATION - Main Entry Point
# ============================================================================
# This is the root Terraform configuration file that orchestrates the 
# provisioning of AWS infrastructure using modular components. It defines
# the AWS provider, instantiates reusable modules, and exposes outputs from
# those modules for easy access to created resources.
#
# Key Responsibilities:
# - Configure AWS provider with region
# - Call EC2 module to provision compute instances
# - Call S3 module to provision storage buckets
# - Aggregate and expose outputs from all modules
# ============================================================================

# AWS Provider Configuration
# Specifies the cloud provider (AWS) and the region where resources will be created.
# Region: ap-south-1 (Asia Pacific - Mumbai) - provides low latency for India-based users
provider "aws" {
  region = "ap-south-1"
}

# ============================================================================
# MODULE DECLARATIONS
# ============================================================================

# EC2 Module - Computes Instances
# This module is responsible for creating and managing EC2 instances (virtual machines)
# Source: ./ec2 directory containing the EC2 resource definitions
# The module is self-contained with its own variables, resources, and outputs
# Variables are passed from root-level inputs to customize per environment
module "ec2_instance" {
  source        = "./ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  tags          = var.tags
}


# S3 Module - Object Storage
# This module is responsible for creating and managing S3 buckets (object storage)
# Source: ./s3 directory containing the S3 resource definitions
# The module is self-contained with its own variables, resources, and outputs
module "s3_bucket" {
  source = "./s3"
  # Uses default variables defined in s3/variables.tf
  # Can be overridden by passing variables here if needed
}

# ============================================================================
# ROOT LEVEL OUTPUTS
# ============================================================================
# These outputs aggregate results from the modules and expose them to the user.
# When 'terraform apply' completes, these values will be displayed in the terminal.
# They can also be referenced by other Terraform configurations or external tools.

# S3 Bucket Name Output
# Retrieves the bucket name created by the S3 module
# Format: module.<module_name>.<output_name>
output "s3_name" {
  description = "The name of the S3 bucket created by the S3 module"
  value       = module.s3_bucket.s3_name
}

# EC2 Instance Public IP Output
# Retrieves the public IP address assigned to the EC2 instance
# This IP can be used to SSH into the instance or access web services
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance for remote access"
  value       = module.ec2_instance.public-ip
}
