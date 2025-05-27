output "main_vm" {
  value = {
    private_ip = aws_instance.main_vm.private_ip
    public_ip  = aws_instance.main_vm.public_ip
  }
  sensitive = true
}
