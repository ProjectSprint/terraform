terraform {
  # Comment the backend if the bucket and dynamodb isn't provisioned yet
  backend "s3" {
    bucket       = "projectsprint-tf-state-a10"
    use_lockfile = true
    key          = "tf-state/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
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
  region = "us-west-2"
}
