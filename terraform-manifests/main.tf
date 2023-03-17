# Configure aws provider
provider "aws" {
    region      = var.region
    profile     = "terraform-user"
}


#Create VPC

module "vpc" {

    source                      = "../modules/vpc"
    region                      = var.region
    project_name                = var.project_name
    vpc_cidr                    = var.vpc_cidr

    public_subnet_az1_cidr      = var.public_subnet_az1_cidr
    public_subnet_az2_cidr      = var.public_subnet_az2_cidr
    public_subnet_az3_cidr      = var.public_subnet_az3_cidr
    public_subnet_az4_cidr      = var.public_subnet_az4_cidr

    private_app_subnet_az1_cidr = var.private_app_subnet_az1_cidr
    private_app_subnet_az2_cidr = var.private_app_subnet_az2_cidr

    private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
    private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

#Create Security Group

module "security_group" {
    source                       = "../modules/security-groups"
    vpc_id                       = module.vpc.vpc_id
}

#Create EC2 Instance

module "ec2" {
    source                      = "../modules/ec2"
    vpc_id                      = module.vpc.vpc_id
    count                       = local.num_instances[var.deployment_stage]
    ami_id                      = "ami-006dcf34c09e50022"
    instance_type               = "t2.micro"
    key_name                    = "terraform-key"

    availability_zone           = data.aws_availability_zones.available.names[count.index]
    subnet_id                   = aws_subnet.subnet[count.index].id
    vpc_security_group_ids      = [aws_security_group.psi_security_group.id]

    tags = {
        Name = "${local.instance_name_prefix[var.deployment_stage]}_${count.index + 1}"

    }
}