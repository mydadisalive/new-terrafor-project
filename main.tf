provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

resource "aws_instance" "example_instance" {
  ami           = "ami-0f34c5ae932e6f0e4" # Replace with your desired AMI ID
  instance_type = "t3.micro"              # Replace with your desired instance type

  # Associate the key pair with the EC2 instance
  key_name = aws_key_pair.my_keypair.key_name

  # Name tag for the EC2 instance
  tags = {
    Name = "example-vm"
  }

  # Provisioner to install and start Nginx on the instance
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user" # Replace with the appropriate username for your EC2 instance
      private_key = file("my-keypair") # Replace with the path to your private key file
      host        = self.public_ip # Use the public IP address of the EC2 instance
    }
    
    inline = [
      "sudo yum update -y",    # Update the package list (Amazon Linux)
      "sudo yum install -y nginx", # Install Nginx
      "sudo systemctl start nginx",   # Start Nginx service
      "sudo systemctl enable nginx"   # Enable Nginx to start on boot
    ]
  }
}

resource "aws_key_pair" "my_keypair" {
  key_name   = "my-keypair" # Replace with your desired key pair name
  public_key = file("my-keypair.pub") # Replace with the path to your public key file
}

# Output the public IP address of the EC2 instance
output "public_ip" {
  value = aws_instance.example_instance.public_ip
}

# Write the public IP address to a file
resource "local_file" "public_ip_file" {
  filename = "public_ip.txt"
  content  = aws_instance.example_instance.public_ip
}