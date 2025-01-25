# Service Discovery
resource "aws_service_discovery_service" "team_discovery" {
  for_each = local.team_ecs_configs
  name     = "${each.key}-service"

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

  tags = {
    project     = "projectsprint"
    environment = "generated"
    team_name   = each.key
  }
}

# ECS Services
resource "aws_ecs_service" "team_services" {
  for_each        = local.team_ecs_configs
  name            = "${each.key}-service"
  cluster         = aws_ecs_cluster.projectsprint.arn
  task_definition = aws_ecs_task_definition.team_tasks[each.key].arn
  desired_count   = each.value.ecs_instances[0].hasEcrImages ? 1 : 0


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
    registry_arn = aws_service_discovery_service.team_discovery[each.key].arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.team_target_groups[each.key].arn
    container_name   = "${each.key}-container"
    container_port   = 8080
  }

  tags = {
    project     = "projectsprint"
    environment = "generated"
    team_name   = each.key
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "team_tasks" {
  for_each                 = local.team_ecs_configs
  family                   = "${each.key}-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = each.value.ecs_instances[0].vCpu
  memory                   = each.value.ecs_instances[0].memory
  execution_role_arn       = aws_iam_role.projectsprint_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.projectsprint_ecs_task.arn

  container_definitions = jsonencode([{
    name      = "${each.key}-container"
    image     = "${module.team_ecr[each.key].repository_url}:latest"
    cpu       = each.value.ecs_instances[0].vCpu
    memory    = each.value.ecs_instances[0].memory
    essential = true

    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]

    environment = [
      { name = "PORT", value = "8080" },
      { name = "AWS_ACCESS_KEY_ID", value = module.projectsprint_iam_account[each.key].iam_access_key_id },
      { name = "AWS_SECRET_ACCESS_KEY", value = module.projectsprint_iam_account[each.key].iam_access_key_secret },
      { name = "AWS_S3_BUCKET_NAME", value = "projectsprint-bucket-public-read" },
      { name = "AWS_REGION", value = var.region }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.team_logs[each.key].name
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
    environment = "generated"
    team_name   = each.key
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "team_logs" {
  for_each          = local.team_ecs_configs
  name              = "/ecs/service/projectsprint-${each.key}"
  retention_in_days = 7

  tags = {
    project     = "projectsprint"
    environment = "generated"
    team_name   = each.key
  }
}

