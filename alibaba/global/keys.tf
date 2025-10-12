resource "alicloud_key_pair" "projectsprint_ops_vm_key" {
  key_pair_name = "projectsprint_ops_vm_key"
  public_key    = var.projectsprint_ops_vm_key
}
