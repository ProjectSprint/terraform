resource "google_sql_database_instance" "projectsprint" {
  name             = "ps-instance"
  database_version = "POSTGRES_17"
  region           = local.region

  settings {
    tier    = "db-f1-micro"
    edition = "ENTERPRISE"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "ops-instance"
        value = "${google_compute_instance.ops.network_interface[0].access_config[0].nat_ip}/32"
      }
    }
  }
}
