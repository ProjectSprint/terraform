terraform {
  backend "s3" {
    bucket         = "projectsprint-tf-state"
    dynamodb_table = "projectsprint-tf-state"
    key            = "tf-state/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
