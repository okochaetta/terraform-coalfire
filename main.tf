# ============================================
# TERRAFORM LOCALS
# ============================================
locals {
    application = "ony"
}

# ============================================
# NETWORK MODULE
# ============================================
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.1.0.0/16"
  application    = local.application

  public_subnets = [
    "10.1.0.0/24",
    "10.1.1.0/24"
  ]

  private_subnets = [
    "10.1.2.0/24",
    "10.1.3.0/24"
  ]
}


# ========================================================================================
# EC2 MODULE 
# Basitan host
# https://gmusumeci.medium.com/how-to-deploy-a-red-hat-enterprise-linux-rhel-ec2-instance-in-aws-using-terraform-6570ad6ee19f
# ========================================================================================
module "bastian" {
  source = "./modules/ec2"
  
  instance_name = "bastian-host-dev"
  application   = local.application
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[1]
  key_pair_name = aws_key_pair.bastian.key_name
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate SSH Keys and Upload them to AWS Key pair
# https://stackoverflow.com/questions/49743220/how-do-i-create-an-ssh-key-in-terraform
# https://www.phillipsj.net/posts/generating-ssh-keys-with-terraform/
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "tls_private_key" "bastian" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastian" {
  key_name   = "bastian-host-key"
  public_key = tls_private_key.bastian.public_key_openssh
}

resource "local_file" "this" {
  content         = tls_private_key.bastian.private_key_pem
  filename        = "./bastian-host-private.pem"
  file_permission = "0600"
}


# ========================================================================================
# ALB WITH AUTOSCALING GROUP  
# ========================================================================================
module "web" {
  source = "./modules/asg"
  
  application = local.application

  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  load_balancer_subnet_ids = module.vpc.public_subnet_ids
}

# ========================================================================================
# S3 MODULE 
# ========================================================================================
module "s3" {
  source = "./modules/s3"
  
  s3_bucket_name = "${local.application}-dev-bucket-lifcyle-policy"
  application    = local.application  

  s3_bucket_objects = [
    "Logs",
    "Images"
  ]
}
