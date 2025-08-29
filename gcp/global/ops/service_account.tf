resource "google_service_account" "ops" {
  account_id   = "ops-sa"
  display_name = "this handles landing page, registration and bots in ProjectSprint"
  depends_on = [
    google_project_service.compute,
    google_project_service.iam
  ]
}

resource "google_service_account" "projectsprint_bucket" {
  account_id   = "projectsprint-bucket-s3"
  display_name = "Service Account for S3-compatible GCS access"
  description  = "Service account with HMAC keys for S3-compatible API access to GCS"
}

# Grant the service account storage admin permissions on the bucket
# Use storage.objectAdmin for full access including listing
# Use storage.objectUser for read/write without listing
# Use storage.objectCreator for write-only without listing
resource "google_storage_bucket_iam_member" "bucket_admin" {
  bucket = google_storage_bucket.projectsprint_ops.name
  role   = "roles/storage.objectAdmin" # Change to storage.objectUser or storage.objectCreator to prevent listing
  member = "serviceAccount:${google_service_account.projectsprint_bucket.email}"
}

resource "google_storage_hmac_key" "projectsprint_bucket_s3_key" {
  service_account_email = google_service_account.projectsprint_bucket.email
  project               = var.project_id
}

