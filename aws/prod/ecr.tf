# module "projectspint_ecr_policy" {
#  for_each = {
#    for team, config in var.projectsprint_teams :
#    team => config if config.start_ecs
#  }
#  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
#  version = "5.37.1"
# 
#  name = "projectspint-ecr-${each.key}"
#  path = "/"
#  policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect = "Allow"
#        Action = [
#          "ecr:DescribeRepositories",
#          "ecr:GetRegistryScanningConfiguration",
#          "ecr:GetAuthorizationToken",
#        ]
#        Resource = "*"
#      },
#      {
#        Effect = "Allow"
#        Action = [
#          "ecr:*",
#        ]
#        Resource = [
#          module.projectsprint_ecr[each.key].repository_arn,
#        ]
#      },
#      {
#        Effect = "Deny"
#        Action = [
#          "ecr:DeleteRepository",
#          "ecr:DeleteRepositoryPolicy",
#          "ecr:PutImageTagMutability",         # Deny edit action
#          "ecr:PutImageScanningConfiguration", # Allow scan on push
#        ]
#        Resource = "*"
#      },
#    ]
#  })
# 
# 
# esource "aws_iam_user_policy_attachment" "projectsprint_ecr" {
#  for_each = {
#    for team, config in var.projectsprint_teams :
#    team => config if config.start_ecs
#  }
# 
#  user       = module.projectsprint_iam_account[each.key].iam_user_name
#  policy_arn = module.projectspint_ecr_policy[each.key].arn
# 
# 
# / https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest#outputs
# odule "projectsprint_ecr" {
#  for_each = {
#    for team, config in var.projectsprint_teams :
#    team => config if config.start_ecs
#  }
#  source = "terraform-aws-modules/ecr/aws"
# 
#  repository_name = "${each.key}-repository"
#  # repository_type = "public"
#  repository_image_tag_mutability   = "MUTABLE"
#  repository_force_delete           = true
#  repository_read_write_access_arns = [module.projectsprint_iam_account[each.key].iam_user_arn]
#  repository_lifecycle_policy = jsonencode({
#    rules = [
#      {
#        rulePriority = 1,
#        description  = "Keep last 10 images",
#        selection = {
#          tagStatus     = "tagged",
#          tagPrefixList = ["v"],
#          countType     = "imageCountMoreThan",
#          countNumber   = 10
#        },
#        action = {
#          type = "expire"
#        }
#      }
#    ]
#  })
# 
#  tags = {
#    Terraform   = "true"
#    Environment = "dev"
#  }
# 
