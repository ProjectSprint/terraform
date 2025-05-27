locals {
  s3_backend_name = "projectsprint-tf-state-b10"
}

module "s3-tf-state" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = local.s3_backend_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}

module "dynamodb-tf-state-lock" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  name           = local.s3_backend_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 3
  write_capacity = 3

  hash_key = "LockID"
  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}

