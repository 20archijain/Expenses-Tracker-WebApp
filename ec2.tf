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

  name = "expense-tracker-instance"

  instance_type = "t3.micro"
  key_name      = "project"
  monitoring    = true

  subnet_id = "subnet-026217194928dec19"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

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