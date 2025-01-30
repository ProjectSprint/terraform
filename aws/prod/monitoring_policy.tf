resource "aws_iam_user_policy" "prometheus_cloudwatch" {
  name = "prometheus-cloudwatch-policy"
  user = module.projectsprint_monitoring_iam_account.iam_user_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "ecs:Describe*",
          "ecs:List*",
          "ecs:Get*",
          "ec2:Describe*",
          "logs:Describe*",
          "logs:Get*",
          "logs:Start*",
          "logs:Stop*",
          "logs:Filter*",
          "logs:Filter*",
          "rds:Describe*",
          "rds:List*",
          "pi:Describe*",
          "pi:List*",
        ]
        Resource = "*"
      }
    ]
  })
}
