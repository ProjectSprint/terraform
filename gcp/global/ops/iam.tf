resource "google_project_iam_member" "ps_sa_service_account_admin" {
  project = local.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.ps_sa_service_account.email}"
}

resource "google_storage_bucket_iam_member" "ps_sa_service_account_admin" {
  bucket = google_storage_bucket.projectsprint_ops.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.ps_sa_service_account.email}"
}

resource "google_artifact_registry_repository" "ps_docker_repo" {
  location      = local.free_tier_region
  repository_id = "ps-docker-repo"
  description   = "Public ProjectSprint Docker repository"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "public_read" {
  project    = local.project_id
  location   = google_artifact_registry_repository.ps_docker_repo.location
  repository = google_artifact_registry_repository.ps_docker_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

resource "google_artifact_registry_repository_iam_member" "ps_write" {
  project    = local.project_id
  location   = google_artifact_registry_repository.ps_docker_repo.location
  repository = google_artifact_registry_repository.ps_docker_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.ps_sa_service_account.email}"
}

resource "google_storage_bucket_iam_member" "gcr_public_read" {
  bucket = google_storage_bucket.projectsprint_ops.id
  role   = "roles/storage.objectViewer"
  member = "allUsers"

  depends_on = [google_project_service.containerregistry]
}

