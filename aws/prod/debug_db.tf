resource "aws_db_instance" "debug_db" {
  for_each             = var.debug_databases

  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "17.2"
  instance_class       = "db.t4g.micro"
  identifier           = each.key
  storage_type         = "standard"
  username             = "postgres"
  password             = random_string.debug_db_pass[each.key].result
  parameter_group_name = "default.postgres17"
  skip_final_snapshot  = true

  storage_encrypted   = false
  deletion_protection = false

  vpc_security_group_ids = [aws_security_group.projectsprint_db.id]
  db_subnet_group_name   = aws_db_subnet_group.projectsprint_db.name


  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "debug"
  }
}

resource "aws_db_subnet_group" "debug_db_subnet" {
  name       = "debug-db-subnet"
  subnet_ids = [aws_subnet.private_b.id, aws_subnet.private_a.id]
  tags = {
    project = "projectsprint",
    Name    = "debug-db"
  }
}

resource "random_string" "debug_db_pass" {
  for_each = var.debug_databases

  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
