provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "variable_test" {

  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "variable-test"
  }
}