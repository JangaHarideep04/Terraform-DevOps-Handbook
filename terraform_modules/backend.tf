# ============================================================================
# TERRAFORM BACKEND CONFIGURATION - STATE STORAGE
# ============================================================================
# This file configures where Terraform stores the state file.
# By default, Terraform stores state locally, but this is not recommended
# for team environments or production. This configuration uses AWS S3 for
# centralized, shared state storage with locking capabilities.
#
# Benefits of Remote Backend:
# - Centralized state accessible to entire team
# - State locking prevents concurrent modifications
# - Automatic backups and versioning
# - Sensitive data stored securely in AWS
# - Integration with Terraform Cloud/Enterprise
#
# Important Notes:
# - The S3 bucket must exist before applying this configuration
# - AWS credentials must be configured (via aws configure or env vars)
# - DynamoDB table for locking (optional but recommended)
# ============================================================================

terraform {
  # S3 Backend Configuration
  # Stores Terraform state in an AWS S3 bucket
  backend "s3" {
    # Bucket Name
    # The S3 bucket where state will be stored
    # This bucket is created by the S3 module in this project
    # Example: my-terraform-s3-bucket-harideep
    bucket = "my-terraform-s3-bucket-harideep"

    # State File Key (Path within bucket)
    # Allows multiple projects to use the same bucket
    # The state file will be stored at: s3://bucket-name/terraform.tfstate
    key = "terraform.tfstate"

    # AWS Region
    # Region where the S3 bucket is located
    # Must match the region where the bucket was created
    region = "ap-south-1"

    # Enable Encryption
    # Encrypts the state file at rest using AWS KMS
    # Adds an extra layer of security for sensitive data
    encrypt = true

    # DynamoDB Table for State Locking
    # Prevents concurrent Terraform operations that could corrupt state
    # Table must have a primary key named 'LockID'
    # Leave commented if you prefer to create/manage this separately
    # dynamodb_table = "terraform-locks"
  }
}
