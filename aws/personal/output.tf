output "nanda_personal_vm" {
  value = {
    private_ip = aws_instance.nanda_personal_vm.private_ip
    public_ip  = aws_instance.nanda_personal_vm.public_ip
  }
  sensitive = true
}
