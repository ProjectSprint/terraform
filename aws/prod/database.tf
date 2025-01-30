# resource "aws_db_instance" "projectsprint_ops_db" {
#   allocated_storage = 5
#   engine            = "postgres"
#   engine_version    = "17.2"
#   instance_class    = "db.t4g.micro"
#   identifier        = "projectsprint-ops-db"
#   storage_type      = "standard"
#   username          = "postgres"
#   password          = random_string.db_pass[each.key].result
#   parameter_group_name = "default.${each.value.db_type}${each.value.db_type == "postgres" ? "17" : (
#     each.value.db_type == "mysql" ? "8.4" : "11.4"
#   )}"
#   skip_final_snapshot = true
# 
#   storage_encrypted   = false
#   deletion_protection = false
# 
#   vpc_security_group_ids = [aws_security_group.projectsprint_db.id]
#   db_subnet_group_name   = aws_db_subnet_group.projectsprint_db.name
# 
# 
#   tags = {
#     project      = "projectsprint",
#     name         = each.key
#     team_name    = each.value.team
#     instance_idx = each.value.idx
#   }
# }
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "projectsprint_db" {
  for_each = merge([
    for team, config in var.projectsprint_teams : {
      for idx, instance_type in config.db_instances :
      "${team}-${idx}" => {
        team     = team
        instance = instance_type
        idx      = idx
        db_type  = config.db_type
        db_disk  = config.db_disk
      }
    }
  ]...)

  allocated_storage = 5
  engine            = each.value.db_type
  engine_version = each.value.db_type == "postgres" ? "17.2" : (
    each.value.db_type == "mysql" ? "8.4.3" : "11.4.4"
  )
  instance_class = "db.${each.value.instance}"
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
    project      = "projectsprint",
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 10
  monitoring_role_arn                   = aws_iam_role.rds_enhanced_monitoring.arn
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
        team     = team
        instance = instance_type
        idx      = idx
      }
    }
  ]...)

  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
