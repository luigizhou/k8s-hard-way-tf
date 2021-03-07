resource "google_compute_network" "k8s-hard-way" {
  name = "k8s-hard-way"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k8s-hard-way" {
  name          = "k8s-hard-way"
  ip_cidr_range = "10.120.0.0/24"
  network       = google_compute_network.k8s-hard-way.id
}

