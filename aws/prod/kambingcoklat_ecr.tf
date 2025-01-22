module "ecr_policy_kambingcoklat" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "projectsprint-ecr-kambingcoklat" # Fixed typo in name
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:DescribeRepositories",
          "ecr:GetRegistryScanningConfiguration",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:*"
        ]
        Resource = [
          module.ecr_kambingcoklat.repository_arn
        ]
      },
      {
        Effect = "Deny"
        Action = [
          "ecr:DeleteRepository",
          "ecr:DeleteRepositoryPolicy",
          "ecr:PutImageTagMutability",
          "ecr:PutImageScanningConfiguration"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "projectsprint_ecr" {
  user       = module.projectsprint_iam_account["kambingcoklat"].iam_user_name
  policy_arn = module.ecr_policy_kambingcoklat.arn
}

module "ecr_kambingcoklat" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name                   = "kambingcoklat-repository"
  repository_image_tag_mutability   = "MUTABLE"
  repository_force_delete           = true
  repository_read_write_access_arns = [module.projectsprint_iam_account["kambingcoklat"].iam_user_arn]
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
    Terraform   = "true"
    Environment = "dev"
  }
}
