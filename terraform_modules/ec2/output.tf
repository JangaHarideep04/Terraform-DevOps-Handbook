# ============================================================================
# EC2 MODULE - OUTPUT VALUES
# ============================================================================
# Outputs expose important information about created resources to the parent module.
# These values can be referenced by other modules or displayed to the user.
# Outputs make data from this module available to the root configuration.
# ============================================================================

# EC2 Public IP Address Output
# Retrieves and exposes the public IP address assigned to the EC2 instance.
# This IP is essential for:
#   - SSH access (connecting to the instance remotely)
#   - Running web services (HTTP/HTTPS)
#   - Any external communication from/to the instance
output "public-ip" {
  # Description of what this output represents
  description = "The public IPv4 address of the EC2 instance"

  # Value retrieves the public_ip attribute from the aws_instance resource
  # Syntax: <resource_type>.<resource_name>.<attribute>
  # aws_instance: the resource type we created
  # module_ec2: the name we gave to the resource
  # public_ip: the attribute containing the public IP address
  value = aws_instance.module_ec2.public_ip
}
