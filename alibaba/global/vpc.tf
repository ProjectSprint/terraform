resource "alicloud_vpc" "projectsprint" {
  vpc_name   = "projectsprint"
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "projectsprint1" {
  vpc_id       = alicloud_vpc.projectsprint.id
  cidr_block   = "172.16.0.0/24"
  zone_id      = local.zone_jakarta_a
  vswitch_name = "projectsprint"
}
