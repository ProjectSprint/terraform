resource "aws_key_pair" "main_vm" {
  key_name   = "${local.project}-operational"
  public_key = var.projectsprint_ops_vm_key
}
