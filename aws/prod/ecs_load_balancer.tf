resource "aws_lb" "team_alb" {
  for_each = merge([
    for team, config in local.team_ecs_configs : {
      for idx, instance in config.ecs_instances :
      "${team}-${idx}" => {
        team     = team
        instance = instance
        idx      = idx
      }
    }
  ]...)

  name               = "${each.value.team}-${each.value.idx}-instance-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.projectsprint_all_sg.security_group_id]
  subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    project      = "projectsprint"
    name         = each.key
    team_name    = each.value.team
    instance_idx = each.value.idx
  }
}

resource "aws_lb_target_group" "team_target_groups" {
  for_each = merge([
    for team, config in local.team_ecs_configs : {
      for idx, instance in config.ecs_instances :
      "${team}-${idx}" => {
        team     = team
        instance = instance
        idx      = idx
      }
    }
  ]...)

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

resource "aws_lb_listener" "team_listeners" {
  for_each = merge([
    for team, config in local.team_ecs_configs : {
      for idx, instance in config.ecs_instances :
      "${team}-${idx}" => {
        team     = team
        instance = instance
        idx      = idx
      }
    }
  ]...)

  load_balancer_arn = aws_lb.team_alb[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.team_target_groups[each.key].arn
  }
}
