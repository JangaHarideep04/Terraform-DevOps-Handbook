# ============================================================================
# S3 MODULE - OUTPUT VALUES
# ============================================================================
# Outputs expose important information about created resources to the parent module.
# These values can be referenced by other modules or displayed to the user.
# Outputs make data from this module available to the root configuration.
# ============================================================================

# S3 Bucket Name Output
# Retrieves and exposes the name of the created S3 bucket.
# This is useful for:
#   - Creating S3 URLs for accessing objects
#   - Configuring other AWS services to use this bucket
#   - Documenting the bucket name for future reference
output "s3_name" {
  # Description of what this output represents
  description = "The name of the S3 bucket"

  # Value retrieves the bucket attribute from the aws_s3_bucket resource
  # Syntax: <resource_type>.<resource_name>.<attribute>
  # aws_s3_bucket: the resource type we created
  # module_s3: the name we gave to the resource
  # bucket: the attribute containing the bucket name
  value = aws_s3_bucket.module_s3.bucket
}