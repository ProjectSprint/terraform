resource "aws_key_pair" "projectsprint" {
  key_name   = "projectsprint"
  public_key = var.projectsprint_vm_public_key
}
