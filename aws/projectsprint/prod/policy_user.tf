# EC2 View Policy
resource "aws_iam_policy" "projectspint_view" {
  name = "projectspint-view"
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
          "ecr-public:Describe*",
          "ecr-public:List*",
          "ecr-public:Get*",
          "sts:Get*",
          "ecs:Stop*",
          "ecs:Update*",
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
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "ce:*",
          "pricing:*",
          "budgets:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3 Policy
resource "aws_iam_policy" "projectsprint_s3" {
  name = "projectsprint-s3-policy"
  path = "/"

  policy = jsonencode({
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
        Resource = [
          module.projectsprint_bucket.s3_bucket_arn,
          "${module.projectsprint_bucket.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Policy attachments for view permissions
resource "aws_iam_group_policy_attachment" "projectsprint_view" {
  group      = aws_iam_group.projectsprint_developers.name
  policy_arn = aws_iam_policy.projectspint_view.arn
}

# Policy attachments for interacting with s3
resource "aws_iam_group_policy_attachment" "projectsprint_s3" {
  group      = aws_iam_group.projectsprint_developers.name
  policy_arn = aws_iam_policy.projectsprint_s3.arn
}

