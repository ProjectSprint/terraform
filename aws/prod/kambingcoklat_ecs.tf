resource "aws_ecs_service" "kambingcoklat" {
  name            = "kambingcoklat-service"
  cluster         = aws_ecs_cluster.projectsprint.arn
  task_definition = aws_ecs_task_definition.kambingcoklat.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }

  network_configuration {
    subnets = [aws_subnet.private_a.id]
    security_groups = [
      module.projectsprint_all_sg.security_group_id,
    ]
    assign_public_ip = false
  }

  depends_on = [
    aws_ecs_cluster.projectsprint
  ]
}

resource "aws_ecs_task_definition" "kambingcoklat" {
  family                   = "kambingcoklat-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.projectsprint_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.projectsprint_ecs_task.arn

  container_definitions = jsonencode([{
    name = "kambingcoklat-container"
    # Uncomment and update with your actual ECR image
    # image     = "${module.ecr_kambingcoklat.repository_url}:latest"
    cpu       = 256
    memory    = 512
    essential = true

    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]

    environment = [
      { name = "DB_NAME", value = "postgres" },
      { name = "DB_PORT", value = "5432" },
      { name = "DB_USERNAME", value = "postgres" },
      { name = "JWT_SECRET", value = random_string.kambingcoklat_jwt_secret.result },
      { name = "AWS_ACCESS_KEY_ID", value = module.projectsprint_iam_account["kambingcoklat"].iam_access_key_id },
      { name = "AWS_SECRET_ACCESS_KEY", value = module.projectsprint_iam_account["kambingcoklat"].iam_access_key_secret },
      { name = "AWS_S3_BUCKET_NAME", value = "projectsprint-bucket-public-read" },
      { name = "AWS_REGION", value = var.region }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.kambingcoklat.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    mountPoints = [{
      sourceVolume  = "ssl-certs"
      containerPath = "/usr/local/share/ca-certificates/"
      readOnly      = true
    }]

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8080 || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 0
    }
  }])
}

resource "aws_cloudwatch_log_group" "kambingcoklat" {
  name              = "/ecs/service/projectsprint-kambingcoklat"
  retention_in_days = 7
}

resource "random_string" "kambingcoklat_jwt_secret" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
