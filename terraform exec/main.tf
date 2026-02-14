provider "aws" {
    region="ap-south-1"
  
}

resource "aws_instance" "test_import"{
    ami="ami-0317b0f0a0144b137"
    instance_type = "t3.micro"
    key_name = "Test1"
    vpc_security_group_ids = ["sg-0a1d54e4e39ac674f"]

    tags={
        Name="Test-remote-exec"
    }

    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("/Users/harideepjanga/Downloads/Terraform/terraform exec/Test1.pem")
        host = self.public_ip
      
    }

    provisioner "remote-exec" {
        inline = [ "sudo dnf install httpd -y",
        "sudo systemctl start httpd", "sudo systemctl enable httpd" ]
      
    }


}

output "publicip" {
    value = aws_instance.test_import.public_ip
  
}