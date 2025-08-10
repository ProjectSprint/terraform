resource "google_storage_bucket" "backend" {
  name     = "projectsprint-tf-backend"
  location = local.region

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}
