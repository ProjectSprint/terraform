resource "aws_iam_policy" "copilot_policy" {
  name        = "projectsprint-copilot-policy"
  description = "Enforces ECS resource limits and configuration standards for ProjectSprint developers"

  # https://docs.aws.amazon.com/service-authorization/latest/reference/reference_policies_actions-resources-contextkeys.html
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LimitALB"
        Effect = "Deny"
        Action = [
          # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateLoadBalancer.html
          "elasticloadbalancing:CreateLoadBalancer"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "elasticloadbalancing:Scheme"        = "internal"
            "elasticloadbalancing:IpAddressType" = "ipv4"
            "elasticloadbalancing:Type"          = "application"
            "elasticloadbalancing:SubnetMappings:SubnetId" : [
              "subnet-0bfa16281c4e9df40",
              "subnet-0d749e9461f70bf86"
            ]
          },
        }
      },
      {
        Sid    = "LimitCloudWatchLogRetention"
        Effect = "Deny"
        Action = [
          # https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_PutRetentionPolicy.html
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
        Condition = {
          NumericGreaterThan = {
            "logs:retentionInDays" = "7"
          }
        }
      },
      {
        Sid    = "PreventVpcAndSubnetCreation"
        Effect = "Deny"
        Action = [
          "ec2:CreateVpc",
          "ec2:CreateSubnet"
        ]
        Resource = "*"
      },
    ]
  })
}

