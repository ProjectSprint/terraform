locals {
  region          = "us-west-2"
  az              = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
  s3_backend_name = "projectsprint-tf-state-a10"
  project         = "projectsprint"
}

variable "projectsprint_vm_operational_key" {
  type = string
}
