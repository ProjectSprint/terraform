terraform {
  # Comment the backend if the bucket and dynamodb isn't provisioned yet
  backend "s3" {
    bucket       = "projectsprint-ops-tf-state-42g"
    use_lockfile = true
    key          = "tf-state/terraform.tfstate"
    region       = "ap-southeast-1"
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
  region = "ap-southeast-1"
}
