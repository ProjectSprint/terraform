# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service
resource "aws_service_discovery_service" "debug_discovery" {
  name = "debug-services"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.projectsprint.id

    dns_records {
      type = "A"
      ttl  = 10
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  force_destroy = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "debug_services" {
  for_each = toset(var.debug_services)

  name            = "debug-${each.value}-service"
  cluster         = aws_ecs_cluster.projectsprint.arn
  task_definition = aws_ecs_task_definition.debug_task_definitions[each.key].arn
  # IF THE ECR IS STILL EMPTY, CHANGE THIS TO 0!
  desired_count = var.debug_service_configs[each.key].instance_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }

  network_configuration {
    subnets = [aws_subnet.public_a.id]
    security_groups = [
      module.projectsprint_all_sg.security_group_id,
    ]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.debug_discovery.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.debug_target_group.arn
    container_name   = "debug-${each.value}-container-definition"
    container_port   = var.debug_service_configs[each.value].container_port
  }

  depends_on = [
    aws_ecs_cluster.projectsprint
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "debug_task_definitions" {
  for_each = toset(var.debug_services)

  family                   = "debug-${each.value}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.debug_service_configs[each.value].cpu
  memory                   = var.debug_service_configs[each.value].memory
  execution_role_arn       = aws_iam_role.projectsprint_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.projectsprint_ecs_task.arn


  container_definitions = jsonencode([{
    name      = "debug-${each.value}-container-definition"
    image     = "${module.debug_ecr[each.value].repository_url}:latest"
    cpu       = var.debug_service_configs[each.value].cpu
    memory    = var.debug_service_configs[each.value].memory
    essential = true

    portMappings = [{
      containerPort = var.debug_service_configs[each.value].container_port
      hostPort      = var.debug_service_configs[each.value].container_port
      protocol      = "tcp"
    }]

    environment = [
      { name = "PORT", value = tostring(var.debug_service_configs[each.value].container_port) },
      { name = "DB_HOST", value = aws_db_instance.debug_db["debug-${each.key}-db"].address },
      { name = "DB_NAME", value = var.debug_database_configs["debug-${each.key}-db"].db_name },
      { name = "DB_PORT", value = "5432" },
      { name = "DB_USERNAME", value = "postgres" },
      { name = "DB_PASSWORD", value = random_string.debug_db_pass["debug-${each.key}-db"].result },
      { name = "JWT_SECRET", value = random_string.debug_jwt_secret.result },
      { name = "AWS_ACCESS_KEY_ID", value = module.projectsprint_iam_account["debug"].iam_access_key_id },
      { name = "AWS_SECRET_ACCESS_KEY", value = module.projectsprint_iam_account["debug"].iam_access_key_secret },
      { name = "AWS_S3_BUCKET_NAME", value = "projectsprint-bucket-public-read" },
      { name = "AWS_REGION", value = var.region }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.debug_log.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8080/healthz || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 0
    }
  }])
  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "debug"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "debug_log" {
  name              = "/ecs/service/projectsprint-debug"
  retention_in_days = 7
  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "debug"
  }
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "debug_jwt_secret" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
