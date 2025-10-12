data "alicloud_images" "ubuntu" {
  name_regex   = "^ubuntu_24.*64"
  architecture = "x86_64"
  most_recent  = true
}

resource "alicloud_instance" "projectsprint_vm" {
  instance_name   = "projectsprint-ecs"
  instance_type   = "ecs.t5-lc1m1.small"
  image_id        = data.alicloud_images.ubuntu.images[0].id
  vswitch_id      = alicloud_vswitch.projectsprint1.id
  security_groups = [alicloud_security_group.projectsprint.id]

  # Valid values are PayByBandwidth, PayByTraffic
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 100

  key_name = alicloud_key_pair.projectsprint_ops_vm_key.key_pair_name

  # Valid values are ephemeral_ssd, cloud_efficiency, cloud_ssd, cloud_essd, cloud, cloud_auto, cloud_essd_entry
  system_disk_category = "cloud_efficiency"
  system_disk_size     = 40

  tags = {
    Project = "projectsprint"
  }
}

