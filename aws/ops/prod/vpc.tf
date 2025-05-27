# default vpc & subnets
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_default_subnet" "public_az1" {
  availability_zone = local.az[0]
}
resource "aws_default_subnet" "public_az2" {
  availability_zone = local.az[1]
}
resource "aws_default_subnet" "public_az3" {
  availability_zone = local.az[2]
}

