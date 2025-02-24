resource "aws_iam_policy" "mikroserpis_01_rds_replica_policy" {
  name        = "rds-replica-policy"
  description = "Policy to allow creation of RDS read replicas with logical replication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:CreateDBInstanceReadReplica",
          "rds:DescribeDBInstances",
          "rds:ModifyDBInstance",
          "rds:RebootDBInstance",
          "rds:ModifyDBParameterGroup",
          "rds:DescribeDBParameterGroups",
          "rds:DescribeDBClusterParameterGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_db_parameter_group" "mikroserpis_01_db_pg" {
  name        = "mikroserpis-01-db-pg"
  family      = "postgres17"
  description = "Custom parameter group for logical replication and performance tuning"

  # Enable logical replication
  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }

  # Adjusted performance tuning parameters for 1GB RAM
  parameter {
    name         = "shared_buffers"
    value        = "256" # 256MB (25% of total RAM)
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "effective_cache_size"
    value = "768" # 768MB (75% of total RAM)
  }

  parameter {
    name  = "work_mem"
    value = "2048" # 2MB per query (the default is 4096KB)
  }

  parameter {
    name  = "maintenance_work_mem"
    value = "32768" # 32MB
  }

  parameter {
    name         = "wal_buffers"
    value        = "7680" # 7.68MB (the default is 3% of shared_buffers)
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "checkpoint_completion_target"
    value = "0.9" # Spreads checkpoint writes over 90% of checkpoint interval
  }

  parameter {
    name  = "autovacuum_vacuum_cost_limit"
    value = "1000" # Reduced for smaller memory
  }

  parameter {
    name  = "log_statement"
    value = "none"
  }

  tags = {
    project     = "projectsprint"
    environment = "development"
    team_name   = "mikroserpis-01"
  }
}

resource "aws_db_instance" "mikroserpis_01_db" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "17.2"
  instance_class       = "db.t4g.micro"
  identifier           = "mikroserpis-01-db-01"
  db_name              = "mikroserpis01db01"
  storage_type         = "standard"
  username             = "postgres"
  password             = random_string.mikroserpis_01_db_pass.result
  parameter_group_name = aws_db_parameter_group.mikroserpis_01_db_pg.name
  skip_final_snapshot  = true

  storage_encrypted   = false
  deletion_protection = false

  # Enable automated backups (required for read replicas)
  backup_retention_period = 7 # ✅ Keeps backups for 7 days

  vpc_security_group_ids = [aws_security_group.projectsprint_db.id]
  db_subnet_group_name   = aws_db_subnet_group.mikroserpis_01_db.name

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 10
  monitoring_role_arn                   = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    project     = "projectsprint"
    environment = "development"
    team_name   = "mikroserpis-01"
  }
}

resource "aws_db_parameter_group" "mikroserpis_01_db_pg_replica" {
  name        = "mikroserpis-01-db-pg-replica"
  family      = "postgres17"
  description = "Custom parameter group for read replica optimization"

  # Read-optimized parameters
  parameter {
    name         = "shared_buffers"
    value        = "256" # 256MB (25% of total RAM)
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "effective_cache_size"
    value = "768" # 768MB (75% of total RAM)
  }

  parameter {
    name  = "work_mem"
    value = "4096" # this is the default value (higher since this is read-optimized)
  }

  parameter {
    name  = "maintenance_work_mem"
    value = "32768" # 32MB
  }

  parameter {
    name         = "wal_buffers"
    value        = "1024" # 1MB (lower since WAL writes are not a priority)
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "checkpoint_completion_target"
    value = "0.9" # Spreads checkpoint writes over 90% of checkpoint interval
  }

  parameter {
    name  = "autovacuum_vacuum_cost_limit"
    value = "2000" # Higher for read optimization
  }

  parameter {
    name  = "autovacuum_vacuum_cost_delay"
    value = "50" # Reduce autovacuum impact on queries (The default value is 20ms)
  }

  parameter {
    name         = "synchronous_commit"
    value        = "off" # Improves read performance by reducing commit wait time
    apply_method = "pending-reboot"
  }

  # parameter {
  #   name  = "random_page_cost"
  #   value = "1.1" # Lowers cost estimation for index scans to improve query performance (the default is 4.0) - THIS IS FOR SSD STORAGE TYPE
  # }

  parameter {
    name  = "log_statement"
    value = "none"
  }

  tags = {
    project     = "projectsprint"
    environment = "development"
    team_name   = "mikroserpis-01"
  }
}

resource "aws_db_instance" "mikroserpis_01_db_replica" {
  identifier           = "mikroserpis-01-db-01-replica"
  instance_class       = "db.t4g.micro"
  replicate_source_db  = aws_db_instance.mikroserpis_01_db.arn
  storage_type         = "standard"
  skip_final_snapshot  = true
  parameter_group_name = aws_db_parameter_group.mikroserpis_01_db_pg_replica.name

  vpc_security_group_ids = [aws_security_group.projectsprint_db.id]
  db_subnet_group_name   = aws_db_subnet_group.mikroserpis_01_db.name

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 10
  monitoring_role_arn                   = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    project     = "projectsprint"
    environment = "development"
    team_name   = "mikroserpis-01"
    role        = "replica"
  }
}

resource "aws_db_subnet_group" "mikroserpis_01_db" {
  name       = "mikroserpis_01_db"
  subnet_ids = [aws_subnet.private_b.id, aws_subnet.private_a.id]
}

resource "random_string" "mikroserpis_01_db_pass" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
