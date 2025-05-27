locals {
  state_name = "projectsprint-ops-tf-state-42g"
}

resource "aws_s3_bucket" "state" {
  bucket        = local.state_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id


  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_dynamodb_table" "state" {
  name           = local.state_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 3
  write_capacity = 3
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
