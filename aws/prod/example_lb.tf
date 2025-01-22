# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "example" {
  name        = "example-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.projectsprint.id
  target_type = "instance"
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
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.projectsprint_all_sg.security_group_id]
  subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  enable_deletion_protection = false

  tags = {
    Name    = "example-lb"
    project = "projectsprint"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

