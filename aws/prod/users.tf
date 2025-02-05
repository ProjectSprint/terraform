resource "random_string" "password" {
  length  = 33
  special = false
}

variable "projectsprint_teams" {
  type = map(object({
    ec2_instances     = optional(list(string), []) # t2.nano, t2.micro, t4g.small, t4g.medium, t4g.large, t4g.xlarge
    ec2_load_balancer = optional(bool, false)
    ecs_details = optional(object({
      app_name      = optional(string, "")
      service_names = optional(list(string), [])
    }), null)
    db_type          = optional(string, "")
    db_disk          = optional(string, "")       # standard, gp2
    db_instances     = optional(list(string), []) # t4g.micro, t4g.small, t4g.medium, t4g.large, t4g.xlarge
    allow_view       = optional(bool, false)
    allow_create_ec2 = optional(bool, false)
    allow_internet   = optional(bool, false)
  }))

  default = {
    "nanda" = {
      allow_view    = true
      ec2_instances = []
    }
    "example" = {
      allow_view = true
      ecs_details = {
        app_name      = "example-app"
        service_names = ["example-1"]
      }
    }
    # === Microservice teams === #
    "tries-di" = {
      allow_view = true
    }
    "ngikut" = {
      allow_view = true
      ecs_load_balancer = [
        {
          path       = "/",
          toEcsIndex = 0
        },
        {
          path       = "/",
          toEcsIndex = 1
        },
        {
          path       = "/",
          toEcsIndex = 2
        },
      ]
      ecs_instances = [
        {
          vCpu                     = 256
          memory                   = 512
          autoscaleInstancesTo     = 1
          cpuUtilizationTrigger    = 80
          memoryUtilizationTrigger = 80
          hasEcrImages             = true
          useDbFromIndex           = 0 # example usage
        },
        {
          vCpu                     = 256
          memory                   = 512
          autoscaleInstancesTo     = 1
          cpuUtilizationTrigger    = 80
          memoryUtilizationTrigger = 80
          hasEcrImages             = false
          useDbFromIndex           = 0
        },
        {
          vCpu                     = 256
          memory                   = 512
          autoscaleInstancesTo     = 1
          cpuUtilizationTrigger    = 80
          memoryUtilizationTrigger = 80
          hasEcrImages             = false
          useDbFromIndex           = 0
        },
      ]
      db_disk      = "standard",
      db_type      = "postgres",
      db_instances = ["t4g.micro"]
    }
    "6-letters" = {
      allow_view = true
    }
    "sigma-skibidi-dev" = {
      allow_view = true
    }
    "nano-nano" = {
      allow_view = true
    }
    "debug" = {
      allow_view = true
    }
    "malu-malu-tapi-suhu" = {
      allow_view = true
    }
    "mikroserpis-01" = {
      allow_view = true
    }
    "git-gud" = {
      allow_view = true
    }


    # === Monolith teams === #
    "bebas-aja" = {
      allow_view = true
    }
    "scriptward" = {
      allow_view = true
    }
    "semoga-survive" = {
      allow_view = true
    }
    "pengcarry-expo" = {
      allow_view = true
    }
    "ldh" = {
      allow_view = true
    }
    "kambingcoklat" = {
      allow_view = true
    }
    "inosys" = {
      allow_view = true
    }
    "gasblar" = {
      allow_view = true
    }
    "cakalang-fafa" = {
      allow_view = true
    }
    "dev-pelajar" = {
      allow_view = true
    }
  }
}

module "projectsprint_iam_account" {
  for_each = var.projectsprint_teams
  source   = "terraform-aws-modules/iam/aws//modules/iam-user"

  version = "5.33.0"

  name = "projectsprint-${each.key}"

  force_destroy                 = true
  create_iam_user_login_profile = true
  password_length               = 8
  password_reset_required       = false
}


resource "aws_iam_group" "projectsprint_developers" {
  name = "projectsprint-developers"
  path = "/projectsprint_developers/"
}

resource "aws_iam_group_membership" "projectsprint_team" {
  name  = "projectsprint-team"
  users = [for account in module.projectsprint_iam_account : account.iam_user_name]
  group = aws_iam_group.projectsprint_developers.name
}

# monitoring account
module "projectsprint_monitoring_iam_account" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"

  version = "5.33.0"

  name = "projectsprint-monitoring"

  force_destroy                 = true
  create_iam_user_login_profile = true
  password_length               = 8
  password_reset_required       = false
}

data "aws_iam_user" "current_user" {
  user_name = "nanda-terraform"
}

data "aws_caller_identity" "current" {}
