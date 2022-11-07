# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MANDATORY VARIABLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "s3_bucket_name" {
  type        = string
  description = " The name of the bucket."
}

variable "s3_bucket_objects" {
  type        = list(string)
  description = "List of bucket object name that will be created inside the bucket"
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

variable "s3_bucket_acl" {
  type        = string
  description = "The canned ACL to apply on the S3 bucket"
  default     = "private"
}

variable "force_destroy" {
  type        = bool
  description = "deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  default     = false   
}
