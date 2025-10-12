output "ops_instance_details" {
  description = "External IP address of the instance (using try function)"
  value       = try(google_compute_instance.ops.network_interface[0].access_config[0].nat_ip, "No external IP assigned")
  sensitive   = true
}

output "jumphost_instance_details" {
  description = "External IP address of the instance (using try function)"
  value       = try(google_compute_instance.jumphost_instance.network_interface[0].access_config[0].nat_ip, "No external IP assigned")
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

output "ps_sa_service_account_service_account" {
  description = "Email address projectsprint service account"
  value       = google_service_account.ps_sa_service_account.email
}

output "ps_sa_service_account_service_account_key" {
  description = "The private key of the projectsprint service account (base64 encoded)"
  value       = google_service_account_key.ps_sa_service_account.private_key
  sensitive   = true
}

output "ps_registry_url" {
  description = "The ProjectSprint Container Registry URL"
  value       = "gcr.io/${local.project_id}"
}

output "artifact_registry_url" {
  description = "The Artifact Registry URL (if created)"
  value       = "${local.free_tier_region}-docker.pkg.dev/${local.project_id}/public-docker-repo"
}

output "public_access_info" {
  description = "Information about public access"
  value = {
    public_pull_command = "docker pull gcr.io/${local.project_id}/ops:COMMIT_HASH"
    note                = "Images are publicly accessible - no authentication required for pulling"
  }
}
