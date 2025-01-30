resource "aws_lb_target_group" "malutapisuhu_target_group" {
  # use random string as suffix because if modified and gets recreatd, target group with the same name is not allowed
  name        = "malutapisuhu-tg-${random_string.malutapisuhu_lb.result}"
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
    create_before_destroy = true
  }

  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "malutapisuhu"
  }
}

resource "aws_lb_target_group" "ms_upp_svc_target_group" {
  name        = "ms-upp-svc-tg"
  port        = var.malutapisuhu_service_configs["ms-upp-svc"].container_port
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
    create_before_destroy = true
  }

  tags = {
    project     = "projectsprint"
    environment = "development"
    team_name   = "malutapisuhu"
  }
}

resource "aws_lb_target_group" "ms_product_svc_target_group" {
  name        = "ms-product-svc-tg"
  port        = var.malutapisuhu_service_configs["ms-product-svc"].container_port
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
    create_before_destroy = true
  }

  tags = {
    project     = "projectsprint"
    environment = "development"
    team_name   = "malutapisuhu"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "malutapisuhu_lb" {
  name               = "malutapisuhu-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.projectsprint_all_sg.security_group_id]
  subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  enable_deletion_protection = false

  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "malutapisuhu"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener" "malutapisuhu_lb_listener" {
  load_balancer_arn = aws_lb.malutapisuhu_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.malutapisuhu_target_group.arn
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    project     = "projectsprint"
    environment = "development" # or production
    team_name   = "malutapisuhu"
  }
}

resource "aws_lb_listener_rule" "ms_upp_svc_listener_rule" {
  listener_arn = aws_lb_listener.malutapisuhu_lb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ms_upp_svc_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/v1/*"]
    }
  }

  tags = {
    project     = "projectsprint"
    environment = "development"
    team_name   = "malutapisuhu"
  }
}

resource "aws_lb_listener_rule" "ms_product_svc_listener_rule" {
  listener_arn = aws_lb_listener.malutapisuhu_lb_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ms_product_svc_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/v1/products/*"]
    }
  }

  tags = {
    project     = "projectsprint"
    environment = "development"
    team_name   = "malutapisuhu"
  }
}
resource "random_string" "malutapisuhu_lb" {
  length  = 4
  special = false
  upper   = true
  lower   = true
  numeric = true
}
