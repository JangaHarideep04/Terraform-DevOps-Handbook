resource "aws_instance" "module_ec2" {
  # AMI ID (Amazon Machine Image)
  # This ID points to a specific pre-configured operating system image
  # ami-0317b0f0a0144b137 is an Ubuntu 22.04 LTS image in ap-south-1 region
  # Update this if you want to use a different OS (Amazon Linux, CentOS, Windows, etc.)
  ami = var.ami_id

  # Instance Type
  # Defines the computing resources (CPU, memory, storage, networking)
  # t3.micro: Burstable performance instance, eligible for free tier
  # Other options: t3.small, t3.medium, m5.large, c5.xlarge, etc.
  instance_type = var.instance_type

  # Apply tags from module variable
  # Tags are key-value pairs for resource identification and cost tracking
  tags = var.tags
}