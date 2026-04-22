module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "expense-tracker-instance"

  instance_type = "t3.micro"
  key_name      = "project"
  monitoring    = true
  subnet_id     = "subnet-026217194928dec19"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}
provider "aws" {
  region = "ap-south-1"
}