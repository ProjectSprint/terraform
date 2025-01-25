module "iam_policy_projectspint_ec2_view" {
  for_each = {
    for team, config in var.projectsprint_teams : team => config
    if config.allow_view
  }

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "projectspint-ec2-view-${each.key}"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:List*",
          "iam:Get*",
          "dynamodb:List*",
          "dynamodb:Get*",
          "dynamodb:Describe*",
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*",
          "ecs:List*",
          "ecs:Describe*",
          "ecs:Get*",
          "ecr:Describe*",
          "ecr:Get*",
          "ecr:List*",
          "cloudformation:Describe*",
          "rds:Describe*",
          "rds:Get*",
          "rds:List*",
          "s3:Get*",
          "s3:List*",
          "s3:Describe*",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:Get*",
          "elasticloadbalancing:List*",
          "autoscaling:Describe*",
          "autoscaling:Get*",
          "autoscaling:List*",
          "application-autoscaling:Describe*",
          "application-autoscaling:Get*",
          "application-autoscaling:List*",
          "servicecatalog:List*",
          "servicediscovery:List*",
          "servicediscovery:Get*",
          "tag:Get*",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "logs:Describe*",
          "logs:List*",
          "logs:Get*",
          "logs:Start*",
          "logs:Filter*",
        ]
        Resource = "*",
      },
      {
        "Effect" : "Deny",
        "Action" : [
          "ce:*",
          "pricing:*",
          "budgets:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Policy for EC2 creation permissions
module "iam_policy_projectspint_ec2_create" {
  for_each = {
    for team, config in var.projectsprint_teams : team => config
    if config.allow_create_ec2
  }

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"
  # things to consider
  # using the default vpc instead of projectsprint vpc
  # even if they choose projectpint vpc, they still can chose unwanted subnet
  # can still choose to get a public ip
  # keypair name needs to be inputted manually
  # lots of security groups with unclear intention
  name = "projectspint-ec2-create-${each.key}"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:GetAllowedImagesSettings",
        ]
        Resource = "*",
      },
    ]
  })
}

module "projectsprint_s3_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "projectsprint-s3-user-policy"
  path = "/"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:ListAllMyBuckets"
          ]
          Resource = ["*"]
        },
        {
          Effect = "Allow"
          Action = [
            "s3:List*",
            "s3:Get*",
            "s3:Put*",
            "s3:DeleteObject*",
            "s3:CreateSession*",
          ]
          Resource = [module.projectsprint_bucket.s3_bucket_arn, "${module.projectsprint_bucket.s3_bucket_arn}/*"]
        }
      ]
    }
  )
}


# Policy attachments for view permissions
resource "aws_iam_user_policy_attachment" "projectsprint_ec2_view" {
  for_each = {
    for team, config in var.projectsprint_teams : team => config
    if config.allow_view
  }

  user       = module.projectsprint_iam_account[each.key].iam_user_name
  policy_arn = module.iam_policy_projectspint_ec2_view[each.key].arn
}

# Policy attachments for create permissions
resource "aws_iam_user_policy_attachment" "projectsprint_ec2_create" {
  for_each = {
    for team, config in var.projectsprint_teams : team => config
    if config.allow_create_ec2
  }

  user       = module.projectsprint_iam_account[each.key].iam_user_name
  policy_arn = module.iam_policy_projectspint_ec2_create[each.key].arn
}

resource "aws_iam_group_policy_attachment" "projectsprint_s3" {
  group      = aws_iam_group.projectsprint_developers.name
  policy_arn = module.projectsprint_s3_policy.arn
}
# module "projectspint_ecs_user_policy" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.start_ecs
#   }
#   source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   version = "5.37.1"
# 
#   name = "projectspint-ecs-user-policy-${each.key}"
#   path = "/"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ecs:DescribeTaskDefinition",
#           "ecs:ListClusters",
#           "ecs:ListTaskDefinitionFamilies",
#           "ecs:ListTasks",
#           "ecs:DescribeTasks",
#           "ecs:ListTaskDefinitions",
#           "ecs:DescribeServices",
#           "ecs:ListServices",
#           "ecs:ListAccountSettings",
#           "cloudwatch:GetMetricData",
#           "application-autoscaling:DescribeScalingPolicies",
#           "application-autoscaling:DescribeScalableTargets",
#           "servicediscovery:GetService",
#           "servicediscovery:GetNamespace",
#           "servicediscovery:ListNamespaces",
#           "ec2:DescribeNetworkInterfaces",
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ecs:DescribeClusters",
#           "ecs:ListContainerInstances"
#         ]
#         Resource = "${aws_ecs_cluster.projectsprint[0].arn}*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:FilterLogEvents",
#           "logs:StartLiveTail",
#           "logs:DescribeLogStreams",
#           "logs:DescribeLogGroups",
#           "logs:GetLogEvents",
#           "logs:GetLogRecord",
#           "logs:GetQueryResults",
#         ]
#         Resource = [
#           "${aws_cloudwatch_log_group.projectsprint[each.key].arn}*",
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ecs:UpdateService",
#         ]
#         Resource = [
#           "${aws_ecs_service.projectsprint[each.key].id}*",
#         ]
#       },
#     ]
#   })
# }
# 
# resource "aws_iam_user_policy_attachment" "projectsprint_ecs_user" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.start_ecs
#   }
# 
#   user       = module.projectsprint_iam_account[each.key].iam_user_name
#   policy_arn = module.projectspint_ecs_user_policy[each.key].arn
# }
# 
# 
# module "projectspint_ecs_independent_user_policy" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.independent_ecs
#   }
#   source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   version = "5.37.1"
# 
#   name = "projectspint-ecs-user-policy-${each.key}"
#   path = "/"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ecs:ListClusters",
# 
#           "ecs:DescribeTaskDefinition",
#           "ecs:ListTasks",
#           "ecs:DescribeTasks",
#           "ecs:ListTaskDefinitions",
#           "ecs:ListTaskDefinitionFamilies",
#           "ecs:DeregisterTaskDefinition",
#           "ecs:ListAccountSettings",
#           "ecs:RegisterTaskDefinition",
# 
#           "ecs:DescribeServices",
#           "ecs:ListServices",
#           "ecs:UpdateService",
#           "ecs:CreateService",
#           "ecs:DeleteService",
#           "ecs:DescribeCapacityProviders",
# 
#           "cloudwatch:GetMetricData",
# 
#           "cloudformation:CreateStack",
# 
#           "application-autoscaling:DescribeScalingPolicies",
#           "application-autoscaling:DescribeScalableTargets",
# 
#           "servicediscovery:GetService",
#           "servicediscovery:GetNamespace",
#           "servicediscovery:ListNamespaces",
# 
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DescribeVpcs",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeRouteTables",
#           "ec2:DescribeSecurityGroups",
# 
# 
#           "ecr:CreateRepository",
#           "ecr:DeleteRepository",
#           "ecr:DescribeRepositories",
#           "ecr:DescribeImages",
#           "ecr:ListImages",
#           "ecr:PutImage",
# 
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:GetRegistryScanningConfiguration",
#           "ecr:ListTagsForResource",
#           "ecr:GetAuthorizationToken",
# 
#           "ecr:BatchGetImage",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:BatchDeleteImage",
#           "ecr:UploadLayerPart",
#           "ecr:CompleteLayerUpload",
#           "ecr:InitiateLayerUpload",
# 
#           "iam:ListRoles",
#           "iam:PassRole",
#           "iam:GetRole",
# 
#           "logs:FilterLogEvents",
#           "logs:StartLiveTail",
#           "logs:DescribeLogStreams",
#           "logs:DescribeLogGroups",
#           "logs:GetLogEvents",
#           "logs:GetLogRecord",
#           "logs:GetQueryResults",
#           "logs:CreateLogGroup",
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ecs:DescribeClusters",
#           "ecs:ListContainerInstances"
#         ]
#         Resource = "${aws_ecs_cluster.projectsprint[0].arn}*"
#       },
#     ]
#   })
# }
# 
# resource "aws_iam_user_policy_attachment" "projectsprint_ecs_independent_user" {
#   for_each = {
#     for team, config in var.projectsprint_teams :
#     team => config if config.independent_ecs
#   }
# 
#   user       = module.projectsprint_iam_account[each.key].iam_user_name
#   policy_arn = module.projectspint_ecs_independent_user_policy[each.key].arn
# }
