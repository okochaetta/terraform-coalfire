# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TERRAFORM LOCALS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
locals {
  instance_name = var.instance_name == null ? "${var.application}-${var.environment}-ec2" : var.instance_name

  common_tags = {
    Environment     = var.environment
    Owner           = var.owner
    CostCenter      = var.costcenter
    ManagedBy       = "Terraform"
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DATA RESOURCE TO FETCH RHEL 8.5
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
data "aws_ami" "rhel" {
  count = var.ami_id == "" ? 1 : 0

  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-8.5*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EC2 INSTANCE CONFIGURATION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_instance" "main" {
  ami                         = var.ami_id == "" ? data.aws_ami.rhel[0].id : var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_pair_name

  vpc_security_group_ids = [
    aws_security_group.main.id
  ]
  
  root_block_device {
    volume_size           = var.root_block_device_size
    volume_type           = var.root_block_device_type
    delete_on_termination = true
    encrypted             = true
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = local.instance_name
    }
  )
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SECURITY GROUP FOR CONNECTIVITY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_security_group" "main" {
  name        = "${var.application}-${var.environment}-ec2-sg"
  vpc_id      = var.vpc_id
  description = "Allow inbound traffic for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Accept inbound SSH traffic from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
