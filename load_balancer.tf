// Forwarding rule for External Network Load Balancing using Backend Services
resource "google_compute_forwarding_rule" "default" {
  name                  = "kubernetes-the-hard-way"
  region                = "europe-west1"
  port_range            = 6443
    target     = google_compute_target_pool.default.id
    ip_address = google_compute_address.ip_address.address

}

resource "google_compute_target_pool" "default" {
  name = "kubernetes-hard-way-pool"

  instances = [
      "europe-west1-b/controller-0",
        "europe-west1-b/controller-1",
        "europe-west1-b/controller-2"
  ]
  health_checks = [
      google_compute_http_health_check.hc.name
  ]
}

resource "google_compute_http_health_check" "hc" {
  name               = "kubernetes-health-check"
  check_interval_sec = 1
  timeout_sec        = 1
  request_path = "/healthz"
  host = "kubernetes.default.svc.cluster.local"
}