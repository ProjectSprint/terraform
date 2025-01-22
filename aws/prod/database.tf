resource "aws_db_instance" "projectsprint_db" {
  for_each = merge([
    for team, config in var.projectsprint_teams : {
      for idx, instance_type in config.db_instances :
      "${team}-${idx}" => {
        team          = team
        instance_type = instance_type
        db_type       = config.db_type
        db_disk       = config.db_disk
      }
    }
  ]...)

  allocated_storage = 5
  engine            = each.value.db_type
  engine_version = each.value.db_type == "postgres" ? "17.2" : (
    each.value.db_type == "mysql" ? "8.4.3" : "11.4.4"
  )
  instance_class = "db.${each.value.instance_type}"
  identifier     = "projectsprint-${each.key}-db"
  storage_type   = each.value.db_disk
  username       = each.value.db_type == "postgres" ? "postgres" : "admin"
  password       = random_string.db_pass[each.key].result
  parameter_group_name = "default.${each.value.db_type}${each.value.db_type == "postgres" ? "17" : (
    each.value.db_type == "mysql" ? "8.4" : "11.4"
  )}"
  skip_final_snapshot = true

  storage_encrypted   = false
  deletion_protection = false

  vpc_security_group_ids = [aws_security_group.projectsprint_db.id]
  db_subnet_group_name   = aws_db_subnet_group.projectsprint_db.name


  tags = {
    project = "projectsprint",
    Name    = each.key
  }
}

resource "aws_db_subnet_group" "projectsprint_db" {
  name       = "projectsprint-db"
  subnet_ids = [aws_subnet.private_b.id, aws_subnet.private_a.id]
}

resource "random_string" "db_pass" {
  for_each = merge([
    for team, config in var.projectsprint_teams : {
      for idx, instance_type in config.db_instances :
      "${team}-${idx}" => {
        team          = team
        instance_type = instance_type
      }
    }
  ]...)

  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
