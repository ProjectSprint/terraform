# resource "aws_ecs_cluster" "projectsprint" {
#   count = var.projectsprint_ecs_cluster_start ? 1 : 0
#   name  = "projectsprint"
# }
# 
# resource "aws_ecs_cluster_capacity_providers" "projectsprint" {
#   count        = var.projectsprint_ecs_cluster_start ? 1 : 0
#   cluster_name = aws_ecs_cluster.projectsprint[0].name
# 
#   capacity_providers = ["FARGATE_SPOT"]
# 
#   default_capacity_provider_strategy {
#     base              = 0
#     weight            = 1
#     capacity_provider = "FARGATE_SPOT"
#   }
# }
# 
# resource "aws_service_discovery_private_dns_namespace" "projectsprint" {
#   name        = "projectsprint.local"
#   description = "Private DNS namespace for projectsprint"
#   vpc         = module.default-vpc.default_vpc_id
# }
