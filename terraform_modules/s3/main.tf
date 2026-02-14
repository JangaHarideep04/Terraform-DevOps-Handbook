# ============================================================================
# S3 MODULE - OBJECT STORAGE
# ============================================================================
# This module defines the AWS S3 bucket resource configuration.
# S3 (Simple Storage Service) is AWS's scalable object storage service used for
# storing files, backups, static websites, data lakes, and more.
#
# Key Features:
# - Unlimited storage capacity
# - Highly available and durable (99.999999999% durability)
# - Accessible from anywhere via HTTP/HTTPS
# - Fine-grained access control and encryption options
# ============================================================================

# S3 Bucket Resource Definition
# Creates a single AWS S3 bucket for object storage
resource "aws_s3_bucket" "module_s3" {
  # Bucket Name
  # Must be globally unique across all AWS accounts (S3 is a global service)
  # Naming rules:
  #   - 3-63 characters long
  #   - Lowercase letters, numbers, hyphens only
  #   - Must start and end with letter or number
  #   - No consecutive hyphens
  #   - No IP address format (e.g., 192.168.1.1)
  # If bucket name is taken, Terraform will fail - you must choose a different name
  bucket = var.aws_s3
}