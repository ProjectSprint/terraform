resource "aws_key_pair" "projectsprint" {
  key_name   = "projectsprint"
  public_key = var.PROJECTSPRINT_VM_PUBLIC_KEY
}
