resource "aws_instance" "operational" {
# https://cloud-images.ubuntu.com/locator/ec2/
  ami                         = "ami-055720487085a7d9f"
  instance_type               = "t4g.nano"
  subnet_id                   = aws_default_subnet.public_az1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.projectsprint_operational.id
  ]

  key_name = aws_key_pair.projectsprint_operational.key_name

  tags = {
    Name    = "projectsprint_operational"
    project = local.project
  }
}
