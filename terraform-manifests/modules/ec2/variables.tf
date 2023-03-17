variable "ami_id" {
    description = "AMI ID to use for EC2 instance"
}

variable "instance_type" {
    description = "Instance type to use for EC2 instance"
}

variable "subnet_id" {
    description = "ID of subnet to use for EC2 instance"
}

variable "tags" {
    description = "Tags to apply to EC2 instance"
    type        = map(string)
}

variable "ec2_instance_count" {
  description = "EC2 Instance Count"
  type        = number
  default     = 1
}

variable "deployment_stage" {
  default = "DEV"
}

locals {
  num_instances = {
    DEV  = 1
    TEST = 2
    PROD = 4
  }

instance_name_prefix = {
    DEV  = "PSI_Cricket_Dev"
    TEST = "PSI_Cricket_Test"
    PROD = "PSI_Cricket_Prod"
  }
}