# Public Route Table and Association
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.projectsprint.id

  tags = {
    project = local.project
  }
}

# link public route table to igw
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# link public subnets to public route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table and Associations
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.projectsprint.id

  tags = {
    project = local.project
  }
}

# link private subnets to private route table
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
