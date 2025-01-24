# https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest
module "nanda_ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name                   = "nanda-repository"
  repository_image_tag_mutability   = "MUTABLE"
  repository_force_delete           = true
  repository_read_write_access_arns = [module.projectsprint_iam_account["nanda"].iam_user_arn]
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
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "nanda"
  }
}
