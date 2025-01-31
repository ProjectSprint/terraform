# Single shared load balancer
resource "aws_lb" "team_alb" {
  for_each = local.teams_with_lb

  name               = "${each.key}-alb-${random_string.team_load_balancer_suffix[each.key].result}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.projectsprint_all_sg.security_group_id]
  subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    project = "projectsprint"
  }
}
resource "random_string" "team_load_balancer_suffix" {
  for_each = local.teams_with_lb
  length  = 3
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# Target groups for each ECS instance
resource "aws_lb_target_group" "team_target_groups" {
  for_each = local.ecs_target_groups

  name        = "${each.value.team}-${each.value.idx}-instance-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.projectsprint.id
  target_type = "ip"

  health_check {
    path                = "/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }

  tags = {
    project      = "projectsprint"
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }
}

# Single listener for the shared load balancer
resource "aws_lb_listener" "team_listener" {
  for_each = local.teams_with_lb

  load_balancer_arn = aws_lb.team_alb[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  # Default action to return 404
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No matching route found"
      status_code  = "404"
    }
  }
}

# Listener rules for path-based routing
resource "aws_lb_listener_rule" "path_based_rules" {
  for_each = merge([
    for team, config in local.teams_with_lb : {
      for i, rule in config.ecs_load_balancer : "${team}-${i}-toEcs-${rule.toEcsIndex}}" => {
        team         = team
        path         = rule.path
        toEcsIndex   = rule.toEcsIndex
        listener_arn = aws_lb_listener.team_listener[team].arn
      }
    }
  ]...)

  listener_arn = each.value.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.team_target_groups["${each.value.team}-${each.value.toEcsIndex}"].arn
  }

  condition {
    path_pattern {
      values = [each.value.path]
    }
  }
  depends_on = [
    aws_lb_target_group.team_target_groups
  ]
}
