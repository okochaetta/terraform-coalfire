# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TERRAFORM LOCALS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
locals {
  common_tags = {
    Environment     = var.environment
    Owner           = var.owner
    CostCenter      = var.costcenter
    ManagedBy       = "Terraform"
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TERRAFORM DATA SOURCE 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
data "aws_availability_zones" "available" {
  state = "available"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# AWS VPC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostname

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-vpc"
    }
  )
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-igw"
    }
  )
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PUBLIC SUBNET
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-sub${count.index + 1}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-public-route-table"
    }
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "public" {
  vpc = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.public.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-nat-gw"
    }
  )
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PRIVATE SUBNET
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-sub${count.index + 3}"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-private-route-table"
    }
  )
} 

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
