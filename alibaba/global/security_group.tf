resource "alicloud_security_group" "projectsprint" {
  security_group_name = "projectsprint-sg"
  description         = "Security group for the projectsprint ECS and VPN"
  vpc_id              = alicloud_vpc.projectsprint.id
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.projectsprint.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  priority          = 1
  security_group_id = alicloud_security_group.projectsprint.id
  cidr_ip           = "0.0.0.0/0"
}

# Optional: allow HTTP/HTTPS
resource "alicloud_security_group_rule" "allow_web" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/443"
  priority          = 1
  security_group_id = alicloud_security_group.projectsprint.id
  cidr_ip           = "0.0.0.0/0"
}

