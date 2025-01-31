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
          # for copilot cli
          # "ssm:Get*",
          # "cloudformation:Describe*",
          # "cloudformation:List*",
          # "cloudformation:Get*",

          # # arn:aws:ecr:ap-southeast-1:024848467457:repository/example-container*
          # "ecr:*",

          # # arn:aws:ssm:ap-southeast-1:024848467457:parameter/copilot/applications/example-service*
          # "ssm:Delete*",
          # "ssm:DeleteParameter",
          # "ssm:PutParameter",
          # "ssm:AddTagsToResource",

          # # arn:aws:cloudformation:ap-southeast-1:024848467457:stack/example-service*
          # # arn:aws:cloudformation:ap-southeast-1:024848467457:stackset/example-service*
          # "cloudformation:ExecuteChangeSet",
          # "cloudformation:CreateChangeSet",
          # "cloudformation:CreateStack",
          # "cloudformation:CreateStackInstances",
          # "cloudformation:CreateChangeSet",
          # "cloudformation:DeleteStack",
          # "cloudformation:DeleteStackInstances",
          # "cloudformation:DeleteStackSet",
          # "cloudformation:UpdateStackSet",
          # "cloudformation:TagResource",
          # "cloudformation:CreateStackSet",

          # # arn:aws:s3:::stackset-example-service*
          # "s3:CreateBucket",
          # "s3:PutBucketPolicy",
          # "s3:DeleteObjectVersion",

          # # arn:aws:iam::024848467457:role/example-service*
          # "sts:Assume*",
          # "iam:Create*",
          # "iam:TagRole",
          # "iam:DeleteRole",
          # "iam:DeleteRolePolicy",
          # "iam:PutRolePolicy",
          # "iam:AttachRolePolicy",
          # "iam:PassRole",
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

