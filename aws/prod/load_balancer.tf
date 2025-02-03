resource "aws_lb" "projectsprint_ec2_lb" {
  for_each = {
    for team, config in var.projectsprint_teams : team => config
    if config.ec2_load_balancer
  }
  name               = "${each.key}-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.projectsprint_all_sg.security_group_id]
  subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  enable_deletion_protection = false

  tags = {
    Name    = "projectsprint-${each.key}-load-balancer"
    project = "projectsprint"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "projectsprint_ec2_lb_listener" {
  for_each = { for team, config in var.projectsprint_teams :
  team => config if config.ec2_load_balancer }
  load_balancer_arn = aws_lb.projectsprint_ec2_lb[each.key].arn
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
#resource "aws_lb_listener_rule" "path_based_rules" {
#  for_each = merge([
#    for team, config in local.teams_with_lb : {
#      for i, rule in config.ecs_load_balancer : "${team}-${i}-toEcs-${rule.toEcsIndex}}" => {
#        team         = team
#        path         = rule.path
#        toEcsIndex   = rule.toEcsIndex
#        listener_arn = aws_lb_listener.team_listener[team].arn
#      }
#    }
#  ]...)
#
#  listener_arn = each.value.listener_arn
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.team_target_groups["${each.value.team}-${each.value.toEcsIndex}"].arn
#  }
#
#  condition {
#    path_pattern {
#      values = [each.value.path]
#    }
#  }
#  depends_on = [
#    aws_lb_target_group.team_target_groups
#  ]
#}

resource "aws_lb_target_group" "projectsprint_ec2_tg" {
  for_each = {
    for team, config in var.projectsprint_teams : team => config
    if config.ec2_load_balancer
  }
  name        = "${each.key}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.projectsprint.id
  target_type = "instance"

  health_check {
    path                = "/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}


resource "aws_lb_target_group_attachment" "projectsprint_ec2_tg_attachment" {
  for_each = merge([
    for team, config in var.projectsprint_teams :
    config.ec2_load_balancer ? {
      for idx, _ in config.ec2_instances : "${team}_${idx}" => {
        team             = team
        instance_id      = aws_instance.projectsprint_ec2["${team}_${idx}"].id
        target_group_arn = aws_lb_target_group.projectsprint_ec2_tg[team].arn
      }
    } : {}
  ]...)

  target_group_arn = each.value.target_group_arn
  target_id        = each.value.instance_id
  port             = 8080
}

