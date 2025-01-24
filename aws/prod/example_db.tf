resource "aws_db_instance" "example_db" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "17.2"
  instance_class       = "db.t4g.micro"
  identifier           = "example-db"
  storage_type         = "standard"
  username             = "postgres"
  password             = random_string.example_db_pass.result
  parameter_group_name = "default.postgres17"
  skip_final_snapshot  = true

  storage_encrypted   = false
  deletion_protection = false

  vpc_security_group_ids = [aws_security_group.projectsprint_db.id]
  db_subnet_group_name   = aws_db_subnet_group.projectsprint_db.name


  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "example"
  }
}

resource "aws_db_subnet_group" "example_db_subnet" {
  name       = "example-db-subnet"
  subnet_ids = [aws_subnet.private_b.id, aws_subnet.private_a.id]
  tags = {
    project = "projectsprint",
    Name    = "example-db"
  }
}

resource "random_string" "example_db_pass" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
