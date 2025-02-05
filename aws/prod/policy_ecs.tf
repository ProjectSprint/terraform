locals {
  teams_with_ecs = {
    for team, config in var.projectsprint_teams : team => config
    if config.ecs_details != null
  }

  ecs_apps = {
    for team, config in local.teams_with_ecs : team => config.ecs_details.app_name
    if config.ecs_details.app_name != ""
  }

  ecs_services = {
    for team, config in local.teams_with_ecs : team => {
      app_name = config.ecs_details.app_name
      services = config.ecs_details.service_names
    }
    if length(config.ecs_details.service_names) > 0
  }
}

resource "aws_iam_policy" "ecs_services_policy" {
  for_each = local.ecs_services
  name     = "projectspint-ecs-${each.key}-services-policy"
  path     = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [for service in each.value.services : {
      Effect = "Allow"
      Action = [
        "ecr:*",
      ]
      Resource = "arn:aws:ecr:ap-southeast-1:024848467457:repository/${each.value.app_name}/${service}*"
    }]
  })
}
resource "aws_iam_policy" "ecs_app_policy" {
  for_each = local.ecs_apps
  name     = "projectspint-ecs-${each.key}-app-policy"
  path     = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:Assume*",
          "iam:CreateRole",
          "iam:TagRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:PassRole",
        ]
        Resource = "arn:aws:iam::024848467457:role/${each.value}*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateStackInstances",
          "cloudformation:DeleteStackInstances",
          "cloudformation:DeleteStackSet",
          "cloudformation:UpdateStackSet",
          "cloudformation:TagResource",
          "cloudformation:CreateStackSet",
        ]
        Resource = "arn:aws:cloudformation:ap-southeast-1:024848467457:stackset/${each.value}-infrastructure*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
        ]
        Resource = "arn:aws:kms:ap-southeast-1:024848467457:key/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:DeleteObjectVersion",
          "s3:PutObject",
        ]
        Resource = "arn:aws:s3:::stackset-${each.value}*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:ExecuteChangeSet",
          "cloudformation:CreateChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
        ]
        Resource = "arn:aws:cloudformation:ap-southeast-1:024848467457:stack/${each.value}-infrastructure-roles/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DeleteParameter",
          "ssm:PutParameter",
          "ssm:AddTagsToResource"
        ]
        Resource = [
          "arn:aws:ssm:ap-southeast-1:024848467457:parameter/copilot/applications/${each.value}",
          "arn:aws:ssm:ap-southeast-1:024848467457:parameter/copilot/applications/${each.value}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:Describe*",
          "cloudformation:List*",
          "cloudformation:Get*",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ecs_app_policy_attachments" {
  for_each   = local.ecs_apps
  user       = module.projectsprint_iam_account[each.key].iam_user_name
  policy_arn = aws_iam_policy.ecs_app_policy[each.key].arn
}
resource "aws_iam_user_policy_attachment" "ecs_services_policy_attachments" {
  for_each   = local.ecs_apps
  user       = module.projectsprint_iam_account[each.key].iam_user_name
  policy_arn = aws_iam_policy.ecs_services_policy[each.key].arn
}
