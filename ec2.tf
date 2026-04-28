provider "aws" {
  region = "ap-south-1"
}

# -----------------------------
# Security Group (SSH + App)
# -----------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-ssh-access"
  description = "Allow SSH and App access"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # open for testing
  }

  ingress {
    description = "App Access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# EC2 Instance Module
# -----------------------------
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "auto-instance"

  instance_type = "t3.small"
  key_name      = "project"
  monitoring    = true

  subnet_id = "subnet-026217194928dec19"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = <<-EOF
  #!/bin/bash
  set -e
  yum update -y

  amazon-linux-extras enable docker
  yum install -y docker git -y
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ec2-user
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose

  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose version

  
  

  
  EOF
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# -----------------------------
# Output
# -----------------------------
output "public_ip" {
  value = module.ec2_instance.public_ip
}