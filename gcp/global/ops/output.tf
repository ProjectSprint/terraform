output "external_ip_safe" {
  description = "External IP address of the instance (using try function)"
  value       = try(google_compute_instance.ops.network_interface[0].access_config[0].nat_ip, "No external IP assigned")
}

output "database_details" {
  description = "Database instance details"
  value = {
    name            = google_sql_database_instance.projectsprint.name
    connection_name = google_sql_database_instance.projectsprint.connection_name
    private_ip      = google_sql_database_instance.projectsprint.private_ip_address
    public_ip       = length(google_sql_database_instance.projectsprint.ip_address) > 0 ? google_sql_database_instance.projectsprint.ip_address[0].ip_address : null
    self_link       = google_sql_database_instance.projectsprint.self_link
  }
}
