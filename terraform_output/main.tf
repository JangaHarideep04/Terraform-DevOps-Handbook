provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_instance" "output-instance"{
    ami           = var.aws_instance
    instance_type = var.instance_type

    tags = {
        Name = "MyInstance-output"
  
}
}
