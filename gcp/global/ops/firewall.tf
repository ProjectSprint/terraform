# Firewall rule for HTTP (port 80)
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
  depends_on    = [google_project_service.compute]
}

# Firewall rule for HTTPS (port 443)
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
  depends_on    = [google_project_service.compute]
}

# Firewall rule for SSH (port 22)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
  depends_on    = [google_project_service.compute]
}

# Firewall rule for mongodb (port 51820)
resource "google_compute_firewall" "allow_mongodb_tcp" {
  name    = "allow-mongodb-tcp"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mongodb-server"]
  depends_on    = [google_project_service.compute]
}

# Firewall rule for Wireguard (port 51820)
resource "google_compute_firewall" "allow_wireguard_tcp" {
  name    = "allow-wireguard-tcp"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["51820"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wireguard-server"]
  depends_on    = [google_project_service.compute]
}

resource "google_compute_firewall" "allow_wireguard_udp" {
  name    = "allow-wireguard-udp"
  network = "default"

  allow {
    protocol = "udp"
    ports    = ["51820"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wireguard-server"]
  depends_on    = [google_project_service.compute]
}

resource "google_compute_firewall" "open_vpn_udp" {
  name    = "open-vpn-udp"
  network = "default"

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["open-vpn-server"]
  depends_on    = [google_project_service.compute]
}

resource "google_compute_firewall" "open_vpn_tcp" {
  name    = "open-vpn-tcp"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["open-vpn-server"]
  depends_on    = [google_project_service.compute]
}


resource "google_compute_firewall" "onprem_pc" {
  name    = "onprem-pc"
  network = "default"

  # on prem servers
  allow {
    protocol = "tcp"
    ports = [
      "9022",
      "8022",
      "7022",
      "10022",
      "11022",
    ]
  }

  # testing ports
  allow {
    protocol = "tcp"
    ports    = ["8080", "8081"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["onprem-pc"]
  depends_on    = [google_project_service.compute]
}
