resource "aws_key_pair" "projectsprint_operational" {
  key_name   = "projectsprint_operational"
  public_key = var.projectsprint_vm_operational_key
}
