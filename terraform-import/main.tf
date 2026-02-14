provider "aws" {
  region = "ap-south-1"

}

terraform {
  backend "s3" {
    bucket = "harideep-test-bucket"
    key = "terraform.tfstate"
    region = "ap-south-1"
    
  }
}

resource "aws_instance" "terraform-test" {
  ami           = "ami-0317b0f0a0144b137"
  instance_type = "t3.micro"
  tags = {
    Name = "Terraform-Instance"

  }
}

resource "aws_instance" "import-test" {
  ami= "ami-0317b0f0a0144b137"
    instance_type= "t3.micro"
}



import {
    to = aws_instance.import-test
    id = "i-0f3ba09dddbabee65"
    

}
