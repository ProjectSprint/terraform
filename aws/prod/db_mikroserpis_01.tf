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
          "rds:ModifyDBParameterGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_db_parameter_group" "mikroserpis_01_db_pg" {
  name        = "mikroserpis-01-db-01-rds-replica"
  family      = "postgres17"
  description = "Custom parameter group for logical replication"

  # Enable logical replication
  parameter {
    name  = "rds.logical_replication"
    value = "1"
  }

  parameter {
    name  = "wal_level"
    value = "logical"
  }

  # Performance tuning parameters
  parameter {
    name  = "huge_pages"
    value = "on"
  }

  parameter {
    name  = "work_mem"
    value = "16384" # 16MB in KB
  }

  parameter {
    name  = "maintenance_work_mem"
    value = "131072" # 128MB in KB
  }

  # parameter {
  #   name  = "effective_cache_size"
  #   value = "4096" # Example for 4GB, adjust based on instance memory
  # }

  # parameter {
  #   name  = "shared_buffers"
  #   value = "2048" # Example for 2GB, adjust based on instance memory
  # }

  # parameter {
  #   name  = "autovacuum_vacuum_cost_limit"
  #   value = "2000" # Increase to allow more work per autovacuum cycle
  # }

  parameter {
    name  = "wal_buffers"
    value = "65536" # Increase for write-heavy workloads (64MB)
  }

  parameter {
    name  = "checkpoint_completion_target"
    value = "0.9" # Helps distribute checkpoint I/O more evenly
  }

  # Monitoring and other settings
  parameter {
    name  = "log_statement"
    value = "none"
  }

  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "mikroserpis-01"
  }
}

resource "aws_db_instance" "mikroserpis_01_db" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "17.2"
  instance_class       = "db.t4g.micro"
  identifier           = "mikroserpis-01-db-01"
  db_name              = "mikroserpis-01-db-01"
  storage_type         = "standard"
  username             = "postgres"
  password             = random_string.mikroserpis_01_db_pass.result
  parameter_group_name = aws_db_parameter_group.mikroserpis_01_db_pg.name
  skip_final_snapshot  = true

  storage_encrypted   = false
  deletion_protection = false

  vpc_security_group_ids = [aws_security_group.projectsprint_db.id]
  db_subnet_group_name   = aws_db_subnet_group.mikroserpis_01_db.name

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 10
  monitoring_role_arn                   = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "mikroserpis-01"
  }
}

resource "aws_db_instance" "mikroserpis_01_db_replica" {
  identifier          = "mikroserpis-01-db-01-replica"
  instance_class      = "db.t4g.micro"
  replicate_source_db = aws_db_instance.mikroserpis_01_db.arn
  storage_type        = "standard"
  skip_final_snapshot = true

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
