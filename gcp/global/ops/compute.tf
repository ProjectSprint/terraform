resource "google_compute_instance" "ops" {
  name = "ops-instance"
  // gcloud compute machine-types list --zones=asia-southeast2-a --filter="guestCpus<=2" --sort-by="guestCpus,memoryMb"
  machine_type = "n1-standard-1"
  zone         = "${local.region}-a"

  boot_disk {
    initialize_params {
      // gcloud compute images list | grep "ubuntu.*amd64"
      image = "ubuntu-os-cloud/ubuntu-2504-plucky-amd64-v20250606"
      type  = "pd-standard"
      size  = 50
    }
  }

  allow_stopping_for_update = true

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.projectsprint_ops_vm_key}"
  }

  tags = ["http-server", "https-server", "ssh-server", "wireguard-server"]

  service_account {
    email  = google_service_account.ops.email
    scopes = ["cloud-platform"] // https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
  }
  depends_on = [
    google_project_service.compute,
    google_service_account.ops,
    google_compute_firewall.allow_http,
    google_compute_firewall.allow_https,
    google_compute_firewall.allow_ssh
  ]
}

resource "google_compute_instance" "free_tier_instance" {
  name = "free-tier-instance"
  // gcloud compute machine-types list --zones=asia-southeast2-a --filter="guestCpus<=2" --sort-by="guestCpus,memoryMb"
  machine_type = "e2-micro"
  zone         = "${local.free_tier_region}-a"

  boot_disk {
    initialize_params {
      // gcloud compute images list | grep "ubuntu.*amd64"
      image = "ubuntu-os-cloud/ubuntu-minimal-2404-noble-amd64-v20250818"
      type  = "pd-standard"
      size  = 30
    }
  }

  allow_stopping_for_update = true

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.projectsprint_ops_vm_key}"
  }

  tags = ["ssh-server", "mongodb-server"]

  service_account {
    email  = google_service_account.ops.email
    scopes = ["cloud-platform"] // https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
  }
  depends_on = [
    google_project_service.compute,
    google_service_account.ops,
  ]
}
