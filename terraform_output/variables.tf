variable "aws_instance" {
    description = "AWS instance configuration"
    type = string
    default =  "ami-0317b0f0a0144b137"  # Replace with your desired AMIReplace with your desired instance type
  
}

variable "instance_type" {
    description = "Type of the AWS instance"
    type = string
    default = "t3.micro"  # Replace with your desired instance type
  
}