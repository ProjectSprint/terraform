locals {
  region          = "ap-southeast-1"
  project         = "sprint"
  s3_backend_name = "projectsprint-tf-state"
}

variable "projectsprint_vm_public_key" {
  type    = string
  default = ""
}

variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "default region"
}

