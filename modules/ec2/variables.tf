# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MANDATORY VARIABLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "vpc_id" {
   type = string
   description = "VPC ID in which security group will be placed."
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch instance"
}

variable "key_pair_name" {
  type        = string
  description = "SSH key pair name for connecting to instance"
}

variable "application" {
  type        = string
  description = "Name of the applicatio to use with resource names"    
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OPTIONAL VARIABLES (WITH DEFAULT VALUES)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "instance_name" {
  type        = string
  description = "Name of the instance for tag"
  default     = null
}

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

variable "ami_id" {
  type        = string
  description = "AMI to use for the instance"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for the instance"
  default     = "t2.micro"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC"
  default     = true
}

variable "root_block_device_size" {
  type        = string
  description = "Size of the volume in gibibytes"
  default     = "20"
}

variable "root_block_device_type" {
  type        = string
  description = "Type of volume to be attached to instance."
  default     = "gp2"
}

