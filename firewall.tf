resource "google_compute_firewall" "k8s-allow-internal" {
  name    = "k8s-allow-internal"
  network = google_compute_network.k8s-hard-way.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["10.120.0.0/24"]
}

resource "google_compute_firewall" "k8s-allow-external" {
  name    = "k8s-allow-external"
  network = google_compute_network.k8s-hard-way.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"#
    ports = [ "22", "6443" ]
  }

  source_ranges = ["0.0.0.0/0"]
}