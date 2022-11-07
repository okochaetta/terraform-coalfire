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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# S3 BUCKET WITH LIFECYCLE POLICY
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_s3_bucket" "main" {

  bucket        = var.s3_bucket_name
  acl           = var.s3_bucket_acl
  force_destroy = var.force_destroy

  tags = merge(
    local.common_tags,
    {
      Name = "${var.application}-${var.environment}-bucket"
    }
  )
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE S3 OBJECTS AND LIFECYCLE POLICIES
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
resource "aws_s3_bucket_object" "main" {
  for_each = toset(var.s3_bucket_objects)
  
  bucket = aws_s3_bucket.main.id
  key    = each.value
  source = "/dev/null"
}

resource "aws_s3_bucket_lifecycle_configuration" "delete" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "delete"
    status = "Enabled"
    
    filter {
      prefix = "Logs/"
    }

    expiration {
      days = 90
    }
  }

  depends_on = [
    aws_s3_bucket_object.main
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "glacier" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "glacier"
    status = "Enabled"
    
    filter {
      prefix = "Images/"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }

  depends_on = [
    aws_s3_bucket_object.main
  ]
}
