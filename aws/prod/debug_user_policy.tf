resource "aws_iam_policy" "debug_user_policy" {
  name = "projectspint-debug-policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:Assume*",
          "iam:Create*",
          "iam:TagRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:PassRole",
        ]
        Resource = "arn:aws:iam::024848467457:role/example-app*"
      },
      #{
      #  Effect = "Allow"
      #  Action = [
      #    "s3:CreateBucket",
      #    "s3:PutBucketPolicy",
      #    "s3:DeleteObjectVersion",
      #  ]
      #  Resource = "arn:aws:s3:::stackset-example-app*"
      #},
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
        Resource = "arn:aws:cloudformation:ap-southeast-1:024848467457:stackset/example-app-infrastructure*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:ExecuteChangeSet",
          "cloudformation:CreateChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
        ]
        Resource = "arn:aws:cloudformation:ap-southeast-1:024848467457:stack/example-app-infrastructure-roles/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DeleteParameter",
          "ssm:PutParameter",
          "ssm:AddTagsToResource",
        ]
        Resource = "arn:aws:ssm:ap-southeast-1:024848467457:parameter/copilot/applications/example-app/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
        ]
        Resource = "arn:aws:ecr:ap-southeast-1:024848467457:repository/example-app/example-1*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:Get*",
          "cloudformation:Describe*",
          "cloudformation:List*",
          "cloudformation:Get*",
        ]
        Resource = "*"
      },
    ]
  })
}
# Policy attachments for view permissions
resource "aws_iam_user_policy_attachment" "debug_user_policy" {
  user       = module.projectsprint_iam_account["example"].iam_user_name
  policy_arn = aws_iam_policy.debug_user_policy.arn
}
