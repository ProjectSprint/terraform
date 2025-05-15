# https://cloud-images.ubuntu.com/locator/ec2/
# resource "aws_instance" "projectsprint_k6" {
#   ami                         = "ami-0f3e8503b5770d296"
#   instance_type               = "t3.large"
#   subnet_id                   = aws_subnet.public_a.id
#   key_name                    = aws_key_pair.projectsprint.key_name
#   associate_public_ip_address = true
#   vpc_security_group_ids = [
#     module.projectsprint_all_sg.security_group_id,
#   ]
# 
#   tags = {
#     project = "projectsprint",
#     Name    = "projectsprint-k6"
#   }
# }

resource "aws_instance" "projectsprint_ec2" {
  for_each = merge([
    for team, config in var.projectsprint_teams : {
      for idx, instance_type in config.ec2_instances :
      "${team}_${idx}" => {
        team           = team
        instance_type  = instance_type
        allow_internet = config.allow_internet
      }
    }
  ]...)

  ami                         = startswith(each.value.instance_type, "t4") ? "ami-08e5da245c78d5f03" : "ami-0f3e8503b5770d296"
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.allow_internet ? aws_subnet.public_a.id : aws_subnet.private_a.id
  key_name                    = aws_key_pair.projectsprint.key_name
  ipv6_address_count          = 0
  associate_public_ip_address = each.value.allow_internet
  vpc_security_group_ids = [
    module.projectsprint_all_sg.security_group_id,
  ]

  # Add user_data to configure proxy for all instances
  user_data = each.value.allow_internet ? null : <<-EOF
  #!/bin/bash
  if ! grep -q "HTTP_PROXY=http://${aws_instance.proxy.private_ip}:3128" /etc/environment; then

  # Remove any existing proxy settings
  sed -i '/HTTP_PROXY=/d; /HTTPS_PROXY=/d; /NO_PROXY=/d; /http_proxy=/d; /https_proxy=/d; /no_proxy=/d' /etc/environment
  
  # Append new proxy settings
  cat >> /etc/environment << 'EOL'
  http_proxy=http://${aws_instance.proxy.private_ip}:3128
  https_proxy=http://${aws_instance.proxy.private_ip}:3128
  no_proxy=localhost,127.0.0.1,169.254.169.254
  HTTP_PROXY=http://${aws_instance.proxy.private_ip}:3128
  HTTPS_PROXY=http://${aws_instance.proxy.private_ip}:3128
  NO_PROXY=localhost,127.0.0.1,169.254.169.254
  EOL

  fi;

  if [ ! -f /etc/apt/apt.conf.d/00proxy ] || ! grep -q "${aws_instance.proxy.private_ip}" /etc/apt/apt.conf.d/00proxy; then
  
  # Remove any existing proxy settings
  sed -i '/Acquire::http::Proxy/d; /Acquire::https::Proxy/d' /etc/apt/apt.conf.d/00proxy
  
  # Append new proxy settings
  cat >> /etc/apt/apt.conf.d/00proxy << 'EOL'
  Acquire::http::Proxy "http://${aws_instance.proxy.private_ip}:3128";
  Acquire::https::Proxy "http://${aws_instance.proxy.private_ip}:3128";
  EOL

  fi;

  # Source the environment variables
  source /etc/environment
  EOF
  tags = {
    project = "projectsprint",
    Name    = "projectsprint-${each.key}-vm",
    team    = each.value.team
  }
}

resource "aws_instance" "monitoring" {
  ami                         = "ami-08e5da245c78d5f03"
  instance_type               = "t4g.nano"
  subnet_id                   = aws_subnet.public_a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.monitoring.id
  ]
  key_name = aws_key_pair.projectsprint.key_name

  tags = {
    Name    = "projectsprint-monitoring"
    project = "projectsprint"
  }
}

resource "aws_instance" "proxy" {
  ami           = "ami-08e5da245c78d5f03"
  instance_type = "t4g.nano"
  subnet_id     = aws_subnet.public_a.id
  vpc_security_group_ids = [
    aws_security_group.proxy.id,
  ]
  key_name                    = aws_key_pair.projectsprint.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y squid apache2-utils

              ### SQUID PROXY CONFIG
              cat > /etc/squid/squid.conf <<EOL
              http_port 3128

              # Define our network
              acl localnet src 10.0.0.0/16

              # Basic bandwidth limits
              delay_pools 1
              delay_class 1 1
              delay_parameters 1 500000/800000
              delay_access 1 allow localnet
              delay_access 1 deny all

              # Allow all destinations
              http_access allow localnet
              http_access deny all

              # Some basic performance settings
              maximum_object_size 1024 MB
              cache_mem 256 MB

              # Logging
              access_log daemon:/var/log/squid/access.log combined
              EOL
              
              # Restart squid
              systemctl restart squid

              EOF

  tags = {
    Name    = "projectsprint-proxy"
    project = "projectsprint"
  }
}
