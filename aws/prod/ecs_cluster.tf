resource "aws_ecs_cluster" "projectsprint" {
  name = "projectsprint"
}

resource "aws_ecs_cluster_capacity_providers" "projectsprint_development" {
  cluster_name = aws_ecs_cluster.projectsprint.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_service_discovery_private_dns_namespace" "projectsprint" {
  name        = "projectsprint.local"
  description = "Private DNS namespace for projectsprint"
  vpc         = module.default-vpc.default_vpc_id
}
