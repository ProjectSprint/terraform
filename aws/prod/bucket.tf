# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "projectsprint_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.3.0"

  bucket                  = "projectsprint-bucket-public-read"
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  acl           = "public-read"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  lifecycle_rule = [
    {
      id      = "expired_all_files"
      enabled = true
      expiration = {
        days = 1
      }
    }
  ]
}

module "transcript_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.3.0"

  bucket                  = "projectsprint-transcript"
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  acl           = "public-read"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  lifecycle_rule = [
    {
      id      = "expired_all_files"
      enabled = true
      expiration = {
        days = 1
      }
    }
  ]
}
