locals {
  # Flatten team DB configurations
  team_dbs = merge([
    for team, config in var.projectsprint_teams : {
      for idx, instance_type in config.db_instances : "${team}-${idx}" => {
        team     = team
        db_type  = config.db_type
        username = config.db_type == "postgres" ? "postgres" : "admin"
        address  = aws_db_instance.projectsprint_db["${team}-${idx}"].address
        password = random_string.db_pass["${team}-${idx}"].result
        port     = aws_db_instance.projectsprint_db["${team}-${idx}"].port
      }
    }
  ]...)

  # Map ECS instances to their DBs
  ecs_db_configs = {
    for team, config in var.projectsprint_teams : team => [
      for idx, instance in config.ecs_instances : {
        db = instance.useDbFromIndex != null ? local.team_dbs["${team}-${instance.useDbFromIndex}"] : null
      }
    ]
  }
}
# Service Discovery
resource "aws_service_discovery_service" "team_discovery" {
  for_each = merge([
    for team, config in local.team_ecs_configs : {
      for idx, instance in config.ecs_instances :
      "${team}-${idx}" => {
        team     = team
        instance = instance
        idx      = idx
      }
    }
  ]...)

  name = "${each.key}-ecs-discovery"

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
    project      = "projectsprint"
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }
}

# ECS Services
resource "aws_ecs_service" "team_services" {
  for_each = merge([
    for team, config in local.team_ecs_configs : {
      for idx, instance in config.ecs_instances :
      "${team}-${idx}" => {
        team     = team
        idx      = idx
        instance = instance
      }
    }
  ]...)

  name            = "${each.key}-service"
  cluster         = aws_ecs_cluster.projectsprint.arn
  task_definition = aws_ecs_task_definition.team_tasks[each.key].arn
  desired_count   = each.value.instance.hasEcrImages ? 1 : 0

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
    project      = "projectsprint"
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "team_tasks" {
  for_each = merge([
    for team, config in local.team_ecs_configs : {
      for idx, instance in config.ecs_instances :
      "${team}-${idx}" => {
        team     = team
        instance = instance
        idx      = idx
      }
    }
  ]...)

  family                   = "${each.value.team}-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = each.value.instance.vCpu
  memory                   = each.value.instance.memory
  execution_role_arn       = aws_iam_role.projectsprint_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.projectsprint_ecs_task.arn

  container_definitions = jsonencode([{
    name      = "${each.key}-container"
    image     = "${module.team_ecr[each.key].repository_url}:latest"
    cpu       = each.value.instance.vCpu
    memory    = each.value.instance.memory
    essential = true

    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]

    environment = [
      { name = "PORT", value = "8080" },
      { name = "AWS_ACCESS_KEY_ID", value = module.projectsprint_iam_account[each.value.team].iam_access_key_id },
      { name = "AWS_SECRET_ACCESS_KEY", value = module.projectsprint_iam_account[each.value.team].iam_access_key_secret },
      { name = "AWS_S3_BUCKET_NAME", value = "projectsprint-bucket-public-read" },
      { name = "AWS_REGION", value = var.region },
      #      {
      #        name  = "DB_USERNAME",
      #        value = var.projectsprint_teams[each.value.team].db_type == "postgres" ? "postgres" : "admin"
      #      },
      #      {
      #        name  = "DB_PASSWORD",
      #        value = random_string.db_pass["${each.value.team}-${each.value.instance.useDbFromIndex}"].result
      #      },
      #      {
      #        name  = "DB_HOST",
      #        value = split(":", aws_db_instance.projectsprint_db["${each.value.team}-${each.value.instance.useDbFromIndex}"].endpoint)[0]
      #      },
      #      {
      #        name  = "DB_PORT",
      #        value = tostring(aws_db_instance.projectsprint_db["${each.value.team}-${each.value.instance.useDbFromIndex}"].port)
      #      }
    ]
  }])

  tags = {
    project      = "projectsprint"
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "team_logs" {
  for_each = merge([
    for team, config in local.team_ecs_configs : {
      for idx, instance in config.ecs_instances :
      "${team}-${idx}" => {
        team     = team
        instance = instance
        idx      = idx
      }
    }
  ]...)

  name              = "/aws/ecs/${each.key}/instance-logs"
  retention_in_days = 7

  tags = {
    project      = "projectsprint"
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }
}
