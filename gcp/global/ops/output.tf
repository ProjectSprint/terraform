output "external_ip_safe" {
  description = "External IP address of the instance (using try function)"
  value       = try(google_compute_instance.ops.network_interface[0].access_config[0].nat_ip, "No external IP assigned")
}
