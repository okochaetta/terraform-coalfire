# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MANDATORY VARIABLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "vpc_id" {
  type        = string
  description = "VPC ID in which security group will be placed."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "VPC Subnet ID to launch instances"
}

variable "load_balancer_subnet_ids" {
  type        = list(string)
  description = "VPC Subnet ID to launch application load balancers"  
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

variable "image_id" {
  type        = string
  description = "AMI ID to use for the instance"
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
  default     = false
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

variable "health_check_type" {
  type        = string
  description = "Type of healthcheck probe"
  default     = "ELB"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum size of the Auto Scaling Group"
  default     = 2
}

variable "asg_max_size" {
  type        = number
  description = "Maximum size of the Auto Scaling Group"
  default     = 6
}

variable "alb_listener_port" {
  type        = number
  description = " Port on which the load balancer is listening"
  default     = 80
}

variable "alb_listener_protocol" {
  type        = string
  description = "Protocol for connections from clients to the load balancer"
  default     = "HTTP"
}

variable "backend_web_port" {
  type        = number
  description = "Port on which targets receive traffic"
  default     = 80
}

