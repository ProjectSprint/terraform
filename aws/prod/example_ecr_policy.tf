# https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-policy
module "example_ecr_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  # we use suffix because policy can't be recreated when it's in use
  name = "example-ecr-${random_string.example_ecr_policy_suffix.result}"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
        ]
        Resource = [
          "arn:aws:ecr:ap-southeast-1:${data.aws_caller_identity.current.account_id }:repository/example-service",
          "arn:aws:ecr:ap-southeast-1:${data.aws_caller_identity.current.account_id }:repository/example-service/*"
        ]
      },
    ]
  })
  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "example"
  }
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "example_ecr_policy_suffix" {
  length  = 4
  special = false
  upper   = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment
resource "aws_iam_user_policy_attachment" "example_ecr_policy" {
  user       = module.projectsprint_iam_account["example"].iam_user_name
  policy_arn = module.example_ecr_policy.arn
}
