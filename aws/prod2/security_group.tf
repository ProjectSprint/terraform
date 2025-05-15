module "projectsprint_all_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"

  name   = "projectsprint-all-sg"
  vpc_id = aws_vpc.projectsprint.id

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = [
    "all-all"
  ]
}

resource "aws_security_group" "monitoring" {
  name        = "projectsprint-monitoring-sg"
  description = "Security group for monitoring"
  vpc_id      = aws_vpc.projectsprint.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.projectsprint.cidr_block]
  }

  # grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.projectsprint.cidr_block]
  }

  # prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.projectsprint.cidr_block]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.projectsprint.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "projectsprint-monitoring-sg"
    project = "projectsprint"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "proxy" {
  name        = "projectsprint-proxy-sg"
  description = "Security group for Squid proxy"
  vpc_id      = aws_vpc.projectsprint.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # openvpn
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # proxy
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.projectsprint.cidr_block]
  }

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "udp"
    cidr_blocks = [aws_vpc.projectsprint.cidr_block]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.projectsprint.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "projectsprint-proxy-sg"
    project = "projectsprint"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "projectsprint_db" {
  name_prefix = "projectsprint-db"

  vpc_id = aws_vpc.projectsprint.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
