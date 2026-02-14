# ============================================================================
# S3 MODULE - INPUT VARIABLES
# ============================================================================
# Variables allow for flexible, reusable module configuration.
# They define inputs that can be customized when the module is called.
# Default values are provided here, but can be overridden in the parent configuration.
# ============================================================================

# S3 Bucket Name Variable
# Specifies the name of the S3 bucket to create
variable "aws_s3" {
  # Type constraint: must be a string
  type = string

  # Default value: unique bucket name for this project
  # Important: S3 bucket names must be globally unique across all AWS accounts
  # If this name is already taken by another AWS account, Terraform will fail
  # To change the name: either modify this default or override it during apply
  default = "my-terraform-s3-bucket-harideep"

  # Description for documentation purposes
  description = "The name of the S3 bucket to create for storing objects"
}
