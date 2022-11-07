# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MANDATORY VARIABLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block for the VPC. CIDR can be explicitly set."    
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IPv4 CIDRs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IPv4 CIDRs"
}

variable "application" {
  type        = string
  description = "Name of the applicatio to use with resource names"    
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OPTIONAL VARIABLES (WITH DEFAULT VALUES)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "environment" {
  type        = string
  description = "Name of the environment in which resources will be created."
  default     = "dev" 
}

variable "owner" {
  type        = string
  description = "Owner of the resources, team or person name"
  default     = "coalfile" 
}

variable "costcenter" {
  type        = string
  description = "Costcenter account Id against which billing will be made."
  default     = "" 
}


variable "instance_tenancy" {
  default     = "default"
  type        = string
  description = "A tenancy option for instances launched into the VPC."
}

variable "enable_dns_support" {
  default     = true
  type        = bool
  description = " A boolean flag to enable/disable DNS support in the VPC"
}

variable "enable_dns_hostname" {
  default     = true
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}

