output "projectsprint_operational" {
  value = {
    private_ip = aws_instance.operational.private_ip
    public_ip  = aws_instance.operational.public_ip
  }
  sensitive   = true
  description = "projectsprint operational instance IP address"
}
