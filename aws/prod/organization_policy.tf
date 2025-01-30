resource "aws_iam_policy" "ecs_restrictions" {
  name        = "projectsprint-ecs-restrictions"
  description = "Enforces ECS resource limits and configuration standards for ProjectSprint developers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PreventInternetFacingALB"
        Effect = "Deny"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:RequestTag/copilot-environment" = ["*"]
          }
          StringEquals = {
            "elasticloadbalancing:Scheme" = ["internet-facing"]
          }
        }
      },
      {
        Sid    = "OnlyAllowALB"
        Effect = "Deny"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "elasticloadbalancing:Type" = ["application"]
          }
        }
      },
      {
        "Sid" : "LimitCloudWatchLogRetention",
        "Effect" : "Deny",
        "Action" : [
          "logs:PutRetentionPolicy"
        ],
        "Resource" : "*",
        "Condition" : {
          "NumericGreaterThan" : {
            "logs:retentionInDays" : ["7"]
          }
        }
      },
      {
        Sid    = "LimitMaximumAutoScaling"
        Effect = "Deny"
        Action = [
          "application-autoscaling:RegisterScalableTarget"
        ]
        Resource = "*"
        Condition = {
          NumericGreaterThan = {
            "application-autoscaling:MaxCapacity" = ["6"] # Maximum number of tasks
          }
        }
      },
      {
        Sid    = "RestrictECSTaskDefinitionResources"
        Effect = "Deny"
        Action = [
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
        Condition = {
          NumericGreaterThan = {
            "ecs:task-definition-cpu"    = ["256"]
            "ecs:task-definition-memory" = ["512"]
          }
        }
      },
      {
        Sid    = "EnforceECSPlatform"
        Effect = "Deny"
        Action = [
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "ecs:task-definition-architecture" = ["ARM64"]
          }
        }
      },
      {
        Sid    = "EnforceECSOperatingSystem"
        Effect = "Deny"
        Action = [
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "ecs:task-definition-operating-system" = ["LINUX"]
          }
        }
      },
      {
        Sid    = "PreventVPCCreation"
        Effect = "Deny"
        Action = [
          "ec2:CreateVpc",
          "ec2:CreateSubnet"
        ]
        Resource = "*"
      },
      {
        Sid    = "EnforceVPCAndSubnets"
        Effect = "Deny"
        Action = [
          "ecs:CreateService",
          "ecs:UpdateService",
          "ec2:RunInstances",
          "elasticloadbalancing:CreateLoadBalancer"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "ec2:Vpc" : ["vpc-0a17e75ca029d7293"]
          }
        }
      },
      {
        Sid    = "EnforceSubnets"
        Effect = "Deny"
        Action = [
          "ecs:CreateService",
          "ecs:UpdateService",
          "ec2:RunInstances",
          "elasticloadbalancing:CreateLoadBalancer"
        ]
        Resource = "*"
        Condition = {
          "ForAnyValue:StringNotLike" = {
            "ec2:SubnetID" = [
              "subnet-0af9ee19c930ab38a",
              "subnet-034cc76393f7ae314"
            ]
          }
        }
      },
    ]
  })
}

# Attach the policy to the existing IAM group
resource "aws_iam_group_policy_attachment" "projectsprint_ecs_restrictions" {
  group      = aws_iam_group.projectsprint_developers.name
  policy_arn = aws_iam_policy.ecs_restrictions.arn
}
