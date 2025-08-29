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
  force_destroy = false
}

resource "google_storage_bucket" "projectsprint_ops" {
  name     = "projectsprint-ops"
  location = local.free_tier_region

  # Enable uniform bucket-level access (recommended for S3 compatibility)
  uniform_bucket_level_access = true

  # Versioning (optional)
  versioning {
    enabled = false
  }

  # Lifecycle rules (optional)
  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }

  # CORS configuration for web access (optional)
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false
  }

  force_destroy = true
}
