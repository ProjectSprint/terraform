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

resource "google_storage_bucket" "transcription" {
  name     = "projectsprint-transcription"
  location = local.region

  versioning {
    enabled = true
  }
}
