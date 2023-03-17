# IaC DevOps using AWS CodePipeline

## Step-00: Introduction
1. Terraform Backend with backend-config
2. How to create multiple environments related Pipeline with single TF Config files in Terraform ? 
3. As part of Multiple environments we are going to create `dev`, `test` and `prod` environments
4. We are going build IaC DevOps Pipelines using 
- AWS CodeBuild
- AWS CodePipeline
- Github
5. We are going to streamline the `terraform-manifests` create all the required file to support Multiple environments.

## Step-00: Create module for vpc,security-groups and ec2.
## Step-01: c1-versions.tf - Terraform Backends
### Step-01 Add backend block as below 
```t
  # Adding Backend as S3 for Remote State Storage
  backend "s3" { }  
```
### Step-02-01: Create file named `dev.conf`
```t
bucket = "terraform-on-aws-for-ec2"
key    = "iacdevops/dev/terraform.tfstate"
region = "us-east-1" 
dynamodb_table = "iacdevops-dev-tfstate" 
```
### Step-02-02: Create file named `test.conf`
```t
bucket = "terraform-on-aws-for-ec2"
key    = "iacdevops/test/terraform.tfstate"
region = "us-east-1" 
dynamodb_table = "iacdevops-test-tfstate" 
```

### Step-02-03: Create file named `prod.conf`
```t
bucket = "terraform-on-aws-for-ec2"
key    = "iacdevops/prod/terraform.tfstate"
region = "us-east-1" 
dynamodb_table = "iacdevops-prod-tfstate" 

### Step-02-04: Create S3 Bucket related folders for both environments for Terraform State Storage
- Go to Services -> S3 -> terraform-on-aws-for-ec2
- Create Folder `iacdevops`
- Create Folder `iacdevops\dev`
- Create Folder `iacdevops\test`
- Create Folder `iacdevops\prod`

### Step-02-05: Create DynamoDB Tables for Both Environments for Terraform State Locking 
- Create Dynamo DB Table for Dev Environment
  - **Table Name:** iacdevops-dev-tfstate
  - **Partition key (Primary Key):** LockID (Type as String)
  - **Table settings:** Use default settings (checked)
  - Click on **Create**
- Create Dynamo DB Table for Test Environment
  - **Table Name:** iacdevops-test-tfstate
  - **Partition key (Primary Key):** LockID (Type as String)
  - **Table settings:** Use default settings (checked)
  - Click on **Create** 
  - Create Dynamo DB Table for Prod Environment
  - **Table Name:** iacdevops-prod-tfstate
  - **Partition key (Primary Key):** LockID (Type as String)
  - **Table settings:** Use default settings (checked)
  - Click on **Create** 

### Step-03-01: dev.tfvars
```t
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
```
### Step-03-02: test.tfvars
```t
# Environment
environment = "PSI_Cricket-Test"
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
private_instance_count = 2
```

### Step-03-03: prod.tfvars
```t
# Environment
environment = "PSI_Cricket-Prod"
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
private_instance_count = 4
```

## Step-04: Create Secure Parameters in Parameter Store
### Step-04-01: Create MY_AWS_SECRET_ACCESS_KEY
- Go to Services -> Systems Manager -> Application Management -> Parameter Store -> Create Parameter 
  - Name: /CodeBuild/MY_AWS_ACCESS_KEY_ID
  - Descritpion: My AWS Access Key ID for Terraform CodePipeline Project
  - Tier: Standard
  - Type: Secure String
  - Rest all defaults
  - Value: ABCXXXXDEFXXXXGHXXX

### Step-04-02: Create MY_AWS_SECRET_ACCESS_KEY
- Go to Services -> Systems Manager -> Application Management -> Parameter Store -> Create Parameter 
  - Name: /CodeBuild/MY_AWS_SECRET_ACCESS_KEY
  - Descritpion: My AWS Secret Access Key for Terraform CodePipeline Project
  - Tier: Standard
  - Type: Secure String
  - Rest all defaults
  - Value: 


## Step-05: buildspec-dev.yml
- Discuss about following Environment variables we are going to pass
- TF_COMMAND
  - We will use `apply` to create resources
  - We will use `destroy` in CodeBuild Environment 
- AWS_ACCESS_KEY_ID: /CodeBuild/MY_AWS_ACCESS_KEY_ID
  - AWS Access Key ID is safely stored in Parameter Store
- AWS_SECRET_ACCESS_KEY: /CodeBuild/MY_AWS_SECRET_ACCESS_KEY
  - AWS Secret Access Key is safely stored in Parameter Store
```yaml
version: 0.2

env:
  variables:
    TERRAFORM_VERSION: "1.4.1"
    TF_COMMAND: "apply"
    #TF_COMMAND: "destroy"
  parameter-store:
    AWS_ACCESS_KEY_ID: "/CodeBuild/MY_AWS_ACCESS_KEY_ID"
    AWS_SECRET_ACCESS_KEY: "/CodeBuild/MY_AWS_SECRET_ACCESS_KEY"

phases:
  install:
    runtime-versions:
      python: 3.10
    on-failure: ABORT       
    commands:
      - tf_version=$TERRAFORM_VERSION
      - wget https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
      - unzip terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
      - mv terraform /usr/local/bin/
  pre_build:
    on-failure: ABORT     
    commands:
      - echo terraform execution started on `date`            
  build:
    on-failure: ABORT   
    commands:
    # AWS vpc,sg and ec2 modules and Dynomodb table
      - cd "$CODEBUILD_SRC_DIR/terraform-manifests"
      - ls -lrt "$CODEBUILD_SRC_DIR/terraform-manifests"
      - terraform --version
      - terraform init -input=false --backend-config=dev.conf
      - terraform validate
      - terraform plan -lock=false -input=false -var-file=dev.tfvars           
      - terraform $TF_COMMAND -input=false -var-file=dev.tfvars -var-file=devdb.tfvars -auto-approve  
  post_build:
    on-failure: CONTINUE   
    commands:
      - echo terraform execution completed on `date`         
```

## Step-06: buildspec-test.yml 
```yaml
version: 0.2

env:
  variables:
    TERRAFORM_VERSION: "1.4.1"
    TF_COMMAND: "apply"
    #TF_COMMAND: "destroy"
  parameter-store:
    AWS_ACCESS_KEY_ID: "/CodeBuild/MY_AWS_ACCESS_KEY_ID"
    AWS_SECRET_ACCESS_KEY: "/CodeBuild/MY_AWS_SECRET_ACCESS_KEY"

phases:
  install:
    runtime-versions:
      python: 3.10
    on-failure: ABORT       
    commands:
      - tf_version=$TERRAFORM_VERSION
      - wget https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
      - unzip terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
      - mv terraform /usr/local/bin/
  pre_build:
    on-failure: ABORT     
    commands:
      - echo terraform execution started on `date`            
  build:
    on-failure: ABORT   
    commands:
    # Project-1: AWS vpc,sg and ec2 modules and Dynomodb table 
      - cd "$CODEBUILD_SRC_DIR/terraform-manifests"
      - ls -lrt "$CODEBUILD_SRC_DIR/terraform-manifests"
      - terraform --version
      - terraform init -input=false --backend-config=test.conf
      - terraform validate
      - terraform plan -lock=false -input=false -var-file=test.tfvars           
      - terraform $TF_COMMAND -input=false -var-file=test.tfvars -var-file=testdb.tfvars -auto-approve  
  post_build:
    on-failure: CONTINUE   
    commands:
      - echo terraform execution completed on `date`      
                 
```

## Step-07: buildspec-prod.yml 
```yaml
version: 0.2

env:
  variables:
    TERRAFORM_VERSION: "1.4.1"
    TF_COMMAND: "apply"
    #TF_COMMAND: "destroy"
  parameter-store:
    AWS_ACCESS_KEY_ID: "/CodeBuild/MY_AWS_ACCESS_KEY_ID"
    AWS_SECRET_ACCESS_KEY: "/CodeBuild/MY_AWS_SECRET_ACCESS_KEY"

phases:
  install:
    runtime-versions:
      python: 3.10
    on-failure: ABORT       
    commands:
      - tf_version=$TERRAFORM_VERSION
      - wget https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
      - unzip terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
      - mv terraform /usr/local/bin/
  pre_build:
    on-failure: ABORT     
    commands:
      - echo terraform execution started on `date`            
  build:
    on-failure: ABORT   
    commands:
    # Project-1: AWS VPC, ASG, ALB, Route53, ACM, Security Groups and SNS 
      - cd "$CODEBUILD_SRC_DIR/terraform-manifests"
      - ls -lrt "$CODEBUILD_SRC_DIR/terraform-manifests"
      - terraform --version
      - terraform init -input=false --backend-config=prod.conf
      - terraform validate
      - terraform plan -lock=false -input=false -var-file=prod.tfvars           
      - terraform $TF_COMMAND -input=false -var-file=prod.tfvars -var-file=proddb.tfvars -auto-approve  
  post_build:
    on-failure: CONTINUE   
    commands:
      - echo terraform execution completed on `date`      
         
```

## Step-08: Create AWS CodePipeline

## Step-09: Verify the Pipeline created
## Step-10: Re-run the CodePipeline 


## Step-11: Verify Resources

## Step-12: Add Approval Stage before deploying to test environment


## Step-13: Add Testing Environment Deploy Stage

## Step-14: Run the Pipeline 

## Step-15: Verify Testing Environment

