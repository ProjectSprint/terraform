output "ops_instance_details" {
  description = "External IP address of the instance (using try function)"
  value       = try(google_compute_instance.ops.network_interface[0].access_config[0].nat_ip, "No external IP assigned")
  sensitive   = true
}

output "free_tier_instance_details" {
  description = "External IP address of the instance (using try function)"
  value       = try(google_compute_instance.free_tier_instance.network_interface[0].access_config[0].nat_ip, "No external IP assigned")
  sensitive   = true
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
  sensitive = true
}

output "bucket_s3_details" {
  description = "Example configuration for S3 clients"
  value = {
    endpoint         = "https://storage.googleapis.com"
    access_key_id    = google_storage_hmac_key.projectsprint_bucket_s3_key.access_id
    secret_key       = google_storage_hmac_key.projectsprint_bucket_s3_key.secret
    bucket_name      = google_storage_bucket.projectsprint_ops.name
    region           = local.region
    force_path_style = true
  }
  sensitive = true
}
