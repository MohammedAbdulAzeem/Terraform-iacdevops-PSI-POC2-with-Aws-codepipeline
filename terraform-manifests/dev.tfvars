# Environment
environment = "PSI_Cricket-Dev"
# VPC Variables
vpc_name = "vpc"
region = "us-east-1"
vpc_cidr = "10.0.0.0/16"
public_subnet_az1_cidr = "10.0.1.0/24"
public_subnet_az2_cidr = "10.0.2.0/24"
public_subnet_az3_cidr = "10.0.3.0/24"
public_subnet_az4_cidr = "10.0.4.0/24"

private_app_subnet_az1_cidr = "10.0.11.0/24"
private_app_subnet_az2_cidr = "10.0.12.0/24"
private_data_subnet_az1_cidr = "10.0.21.0/24"
private_data_subnet_az2_cidr = "10.0.22.0/24"

# EC2 Instance Variables
instance_type = "t2.micro"
instance_keypair = "terraform-key"
private_instance_count = 1




