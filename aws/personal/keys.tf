resource "aws_key_pair" "nanda_personal_vm" {
  key_name   = "nanda_personal_vm"
  public_key = var.nanda_personal_vm_key

  tags = {
    project = local.project
  }
}
