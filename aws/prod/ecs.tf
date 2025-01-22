# resource "aws_service_discovery_service" "projectsprint" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.start_ecs
#   }
#   name = "${each.key}-service"
#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.projectsprint.id
# 
#     dns_records {
#       type = "A"
#       ttl  = 10
#     }
#   }
#   health_check_custom_config {
#     failure_threshold = 1
#   }
#   force_destroy = true
# }
# resource "aws_ecs_service" "projectsprint" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.start_ecs
#   }
#   name            = "projectsprint-${each.key}-service"
#   cluster         = aws_ecs_cluster.projectsprint[0].arn
#   task_definition = aws_ecs_task_definition.projectsprint[each.key].arn
#   desired_count   = 1
#   capacity_provider_strategy {
#     capacity_provider = each.value.turbo_ecs ? "FARGATE" : "FARGATE_SPOT"
#     weight            = 1
#     base              = 0
#   }
#   network_configuration {
#     subnets = [var.subnet_1a]
#     security_groups = [
#       module.projectsprint_8080_sg.security_group_id,
#     ]
#     assign_public_ip = true
#   }
# 
#   service_registries {
#     registry_arn = aws_service_discovery_service.projectsprint[each.key].arn
#   }
#   depends_on = [
#     aws_ecs_cluster.projectsprint
#   ]
# }
# 
# resource "aws_ecs_task_definition" "projectsprint" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.start_ecs
#   }
#   family                   = "projectsprint-${each.key}-task-definition"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = each.value.turbo_ecs ? 2048 : 256
#   memory                   = each.value.turbo_ecs ? 4096 : 512
#   execution_role_arn       = aws_iam_role.projectsprint_ecs_task_execution.arn
#   task_role_arn            = aws_iam_role.projectsprint_ecs_task.arn
#   volume {
#     name      = "ssl-certs"
#     host_path = var.rds_ca_cert_path_ap_southeast_1
#   }
# 
#   container_definitions = jsonencode([
#     {
#       name      = "${each.key}-container"
#       image     = "${module.projectsprint_ecr[each.key].repository_url}:latest"
#       cpu       = each.value.turbo_ecs ? 2048 : 256
#       memory    = each.value.turbo_ecs ? 4096 : 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 8080
#           hostPort      = 8080
#         }
#       ],
#       environment = [
#         { "name" : "DB_NAME", "value" : "postgres" },
#         { "name" : "DB_PORT", "value" : "5432" },
#         { "name" : "DB_HOST", "value" : "${aws_db_instance.projectsprint_ecs_db[each.key].address}" },
#         { "name" : "DB_USERNAME", "value" : "postgres" },
#         { "name" : "DB_PASSWORD", "value" : "${random_string.db_pass[each.key].result}" },
#         { "name" : "DB_PARAMS", "value" : "sslmode=verify-full" },
#         { "name" : "JWT_SECRET", "value" : "${random_string.jwt_secret[each.key].result}" },
#         { "name" : "BCRYPT_SALT", "value" : "10" },
#         { "name" : "AWS_ACCESS_KEY_ID", "value" : module.projectsprint_iam_account[each.key].iam_access_key_id },
#         { "name" : "AWS_SECRET_ACCESS_KEY", "value" : module.projectsprint_iam_account[each.key].iam_access_key_secret },
#         { "name" : "AWS_S3_BUCKET_NAME", "value" : "projectsprint-bucket-public-read" },
#         { "name" : "AWS_REGION", "value" : var.region },
#       ],
# 
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = aws_cloudwatch_log_group.projectsprint[each.key].name
#           "awslogs-region"        = var.region
#           "awslogs-stream-prefix" = "ecs"
#         }
#       }
#       mountPoints = [
#         {
#           sourceVolume  = "ssl-certs"
#           containerPath = "/usr/local/share/ca-certificates/"
#           readOnly      = true
#         }
#       ]
#       /** 
# 
#       # build a custom image containing the ca certificate to connect to RDS
#       FROM alpine:latest
# 
#       # Install any dependencies or tools needed
#       RUN apk --no-cache add ca-certificates
# 
#       # Copy the RDS CA file to the appropriate directory
#       COPY rds-ca-2019-root.pem /usr/local/share/ca-certificates/
# 
#       # Update the CA certificate store
#       RUN update-ca-certificates
# 
#       # Optionally, include additional steps to configure your application or add other files/resources
# 
#       # Set the default command
#       CMD ["sh"]
# 
#       */
#       # healthCheck = {
#       #   command     = ["CMD-SHELL", "curl -f http://localhost:8080 || exit 1"]
#       #   interval    = 30
#       #   timeout     = 5
#       #   retries     = 3
#       #   startPeriod = 0
#       # }
#     },
#   ])
# 
#   depends_on = [
#   ]
# }
# 
# resource "aws_cloudwatch_log_group" "projectsprint" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.start_ecs
#   }
#   name              = "/ecs/service/projectsprint-${each.key}"
#   retention_in_days = 7
# }
# 
# resource "random_string" "jwt_secret" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.start_ecs
#   }
#   length  = 32
#   special = false
#   upper   = true
#   lower   = true
#   numeric = true
# }
