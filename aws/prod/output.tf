output "root_account_id" {
  value = data.aws_caller_identity.current.account_id
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
output "projectsprint_load_balancers" {
  value = {
    for acc, team in var.projectsprint_teams :
    acc => {
      dns = aws_lb.projectsprint_ec2[acc].dns_name
    }
    if team.ec2_load_balancer
  }
  sensitive = true
}
