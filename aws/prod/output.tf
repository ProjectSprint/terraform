output "root_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "projectsprint_monitoring" {
  value = {
    private_ip = aws_instance.monitoring.private_ip
    public_ip  = aws_instance.monitoring.public_ip
    username   = module.projectsprint_monitoring_iam_account.iam_user_name
    password   = module.projectsprint_monitoring_iam_account.iam_user_login_profile_password
    access_key = module.projectsprint_monitoring_iam_account.iam_access_key_id
    secret_key = module.projectsprint_monitoring_iam_account.iam_access_key_secret
  }
  depends_on  = [aws_instance.monitoring]
  sensitive   = true
  description = "projectsprint monitoring instance IP address"
}

output "projectsprint_proxy" {
  value = {
    private_ip = aws_instance.proxy.private_ip
    public_ip  = aws_instance.proxy.public_ip
  }
  depends_on  = [aws_instance.proxy]
  sensitive   = true
  description = "projectsprint proxy IP address"
}

output "projectsprint_ec2" {
  value = {
    for team in distinct([for k, v in aws_instance.projectsprint_ec2 : split("_", k)[0]]) :
    team => {
      for k, v in aws_instance.projectsprint_ec2 :
      k => v.private_ip if startswith(k, team)
    }
  }
  depends_on  = [aws_instance.projectsprint_ec2]
  sensitive   = true
  description = "projectsprint_ec2 IP addresses grouped by team"
}

output "projectsprint_ecs_discovery" {
  value = {
    for team, config in var.projectsprint_teams :
    team => {
      for k, v in aws_service_discovery_service.team_discovery :
      k => {
        endpoint = "${k}-ecs-discovery"
      } if startswith(k, team)
    }
  }
  depends_on  = [module.team_ecr]
  sensitive   = true
  description = "projectsprint_ecr url info grouped by team"
}

output "projectsprint_ecr" {
  value = {
    for team, config in var.projectsprint_teams :
    team => {
      for k, v in module.team_ecr :
      k => {
        endpoint = v.repository_url
      } if startswith(k, team)
    }
  }
  depends_on  = [module.team_ecr]
  sensitive   = true
  description = "projectsprint_ecr url info grouped by team"
}

output "projectsprint_db" {
  value = {
    for team, config in var.projectsprint_teams :
    team => {
      for k, v in aws_db_instance.projectsprint_db :
      k => {
        endpoint = v.endpoint
        username = v.username
        password = random_string.db_pass[k].result
      } if startswith(k, team)
    } if length(config.db_instances) > 0
  }
  depends_on  = [aws_db_instance.projectsprint_db]
  sensitive   = true
  description = "projectsprint_db connection info grouped by team"
}
output "projectsprint_user_credentials" {
  value = {
    for acc, team in var.projectsprint_teams :
    acc => {
      username   = module.projectsprint_iam_account[acc].iam_user_name
      password   = module.projectsprint_iam_account[acc].iam_user_login_profile_password
      access_key = module.projectsprint_iam_account[acc].iam_access_key_id
      secret_key = module.projectsprint_iam_account[acc].iam_access_key_secret
    }
  }
  sensitive = true
}
output "projectsprint_ec2_load_balancers" {
  value = {
    for acc, team in var.projectsprint_teams :
    acc => {
      dns = aws_lb.projectsprint_ec2[acc].dns_name
    }
    if team.ec2_load_balancer
  }
  sensitive = true
}

output "projectsprint_ecs_load_balancers" {
  value = {
    for team, config in var.projectsprint_teams :
    team => {
      for k, v in aws_lb.team_alb :
      k => {
        endpoint = v.dns_name
      } if startswith(k, team)
    }
  }
  sensitive = true
}
