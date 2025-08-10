provider "google" {
  project = var.google_project_id
  # pricing comparison (e2-micro, spot) 9 Jun 2025
  # Jakarta (asia-southeast2): $2.58
  # Delhi (asia-south2): $2.22
  # Las Vegas (us-west4): $0.85
  region = local.free_tier_region
}
