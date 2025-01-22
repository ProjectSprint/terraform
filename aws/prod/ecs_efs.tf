# resource "aws_efs_file_system" "projectsprint" {
#   count          = var.projectsprint_ecs_cluster_start ? 1 : 0
#   creation_token = "projectsprint-efs"
# 
#   tags = {
#     Name = "projectsprint-efs"
#   }
# }
# 
# resource "aws_efs_mount_target" "projectsprint" {
#   count           = var.projectsprint_ecs_cluster_start ? 1 : 0
#   file_system_id  = aws_efs_file_system.projectsprint[0].id
#   subnet_id       = var.subnet_1a
#   security_groups = [aws_security_group.projectsprint_efs.id]
# }
# 
# resource "aws_security_group" "projectsprint_efs" {
#   name   = "projectsprint-efs-sg"
#   vpc_id = module.default-vpc.default_vpc_id
# 
#   ingress {
#     from_port   = 2049
#     to_port     = 2049
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# 
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
