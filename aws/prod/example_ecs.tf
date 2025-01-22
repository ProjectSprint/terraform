# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service
resource "aws_service_discovery_service" "example" {
  name = "example-service"
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
resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.projectsprint.arn
  task_definition = aws_ecs_task_definition.example.arn
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

  service_registries {
    registry_arn = aws_service_discovery_service.example.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "example-container"
    container_port   = 8080
  }

  depends_on = [
    aws_ecs_cluster.projectsprint
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "example" {
  family                   = "example-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.projectsprint_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.projectsprint_ecs_task.arn

  # Uncomment and update with your actual ECR image
  container_definitions = jsonencode([{
    # name = "example-container"
    # image     = "${module.ecr_example.repository_url}:latest"
    # cpu       = 256
    # memory    = 512
    # essential = true

    # portMappings = [{
    #   containerPort = 8080
    #   hostPort      = 8080
    #   protocol      = "tcp"
    # }]

    # environment = [
    #   { name = "DB_NAME", value = "postgres" },
    #   { name = "DB_PORT", value = "5432" },
    #   { name = "DB_USERNAME", value = "postgres" },
    #   { name = "JWT_SECRET", value = random_string.example_jwt_secret.result },
    #   { name = "AWS_ACCESS_KEY_ID", value = module.projectsprint_iam_account["example"].iam_access_key_id },
    #   { name = "AWS_SECRET_ACCESS_KEY", value = module.projectsprint_iam_account["example"].iam_access_key_secret },
    #   { name = "AWS_S3_BUCKET_NAME", value = "projectsprint-bucket-public-read" },
    #   { name = "AWS_REGION", value = var.region }
    # ]

    # logConfiguration = {
    #   logDriver = "awslogs"
    #   options = {
    #     "awslogs-group"         = aws_cloudwatch_log_group.example.name
    #     "awslogs-region"        = var.region
    #     "awslogs-stream-prefix" = "ecs"
    #   }
    # }

    # healthCheck = {
    #   command     = ["CMD-SHELL", "curl -f http://localhost:8080 || exit 1"]
    #   interval    = 30
    #   timeout     = 5
    #   retries     = 3
    #   startPeriod = 0
    # }
  }])
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "example" {
  name              = "/ecs/service/projectsprint-example"
  retention_in_days = 7
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "example_jwt_secret" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
