module "team_ecr" {
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
  source = "terraform-aws-modules/ecr/aws"

  providers = {
    aws = aws.us-east-1
  }
  repository_name                   = "${each.key}-repository"
  repository_type                   = "public"
  repository_image_tag_mutability   = "MUTABLE"
  repository_force_delete           = true
  repository_read_write_access_arns = [module.projectsprint_iam_account[each.value.team].iam_user_arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    project      = "projectsprint"
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }
}

# ECR Policy per team
module "team_ecr_policy" {
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
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "${each.key}-ecr"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "ecr:BatchDeleteImage",
          "ecr-public:*",
          "sts:Get*",
        ]
        Resource = [
          module.team_ecr[each.key].repository_arn
        ]
      },
    ]
  })
  tags = {
    project      = "projectsprint"
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }
}

resource "random_string" "team_ecr_policy_suffix" {
  for_each = local.team_ecs_configs
  length   = 4
  special  = false
  upper    = false
}

resource "aws_iam_user_policy_attachment" "team_ecr_policy" {
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
  user       = module.projectsprint_iam_account[each.value.team].iam_user_name
  policy_arn = module.team_ecr_policy[each.key].arn
}


