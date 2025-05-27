resource "aws_instance" "main_vm" {
  # check ubuntu image ami code:
  # https://cloud-images.ubuntu.com/locator/ec2/
  ami = "ami-066c8e715dd8c01d8"
  # check instance type pricing:
  # https://instances.vantage.sh
  instance_type               = "t4g.nano"
  subnet_id                   = aws_default_subnet.public_az1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.vm.id
  ]

  key_name = aws_key_pair.main_vm.key_name

  tags = {
    Name    = "${local.project}-vm"
    project = local.project
  }
}
