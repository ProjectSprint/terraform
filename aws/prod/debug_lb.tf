# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "debug_target_group" {
  # use random string as suffix because if modified and gets recreatd, target group with the same name is not allowed
  name        = "debug-tg-${random_string.debug_target_group_suffix.result}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.projectsprint.id
  target_type = "ip"
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  lifecycle {
    # this is here because target group can't be destroyed when it's in use
    create_before_destroy = true
  }

  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "debug"
  }
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "debug_target_group_suffix" {
  length  = 4
  special = false
  upper   = false
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "debug_lb" {
  name               = "debug-lb-${random_string.debug_load_balancer_suffix.result}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.projectsprint_all_sg.security_group_id]
  subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  enable_deletion_protection = false

  lifecycle {
    # this is here because load balancer needs to be created first in order to the listener can attach it properly
    create_before_destroy = true
  }

  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "debug"
  }
}

resource "random_string" "debug_load_balancer_suffix" {
  length  = 3
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener" "debug_lb_listener" {
  load_balancer_arn = aws_lb.debug_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.debug_target_group.arn
  }

  # want custom pathing? Checkout:
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "debug"
  }

}

