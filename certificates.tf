# Create Certificate Authority
module "init-ca" {
  source          = "./submodules/tls-cert-generator"
  cn              = "Kubernetes"
  org             = "Kubernetes"
  ou              = "CA"
  country         = "United Kindgom"
  location        = "London"
  validity_period = 8760
}

resource "local_file" "ca-key" {
    content     = module.init-ca.ca_key
    filename = "certs/ca-key.pem"
}

resource "local_file" "ca-pem" {
    content     = module.init-ca.ca_cert
    filename = "certs/ca.pem"
}

# Generate certificates
module "admin" {
  source          = "./submodules/tls-cert-generator"
  cn              = "admin"
  org             = "system:masters"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  validity_period = 8760
}

resource "local_file" "admin-key" {
    content     = module.admin.key
    filename = "certs/admin-key.pem"
}

resource "local_file" "admin-pem" {
    content     = module.admin.cert
    filename = "certs/admin.pem"
}

module "kube-controller-manager" {
  source          = "./submodules/tls-cert-generator"
  cn              = "system:kube-controller-manager"
  org             = "system:kube-controller-manager"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  validity_period = 8760
}
resource "local_file" "kube-controller-manager-key" {
    content     = module.kube-controller-manager.key
    filename = "certs/kube-controller-manager-key.pem"
}

resource "local_file" "kube-controller-manager-pem" {
    content     = module.kube-controller-manager.cert
    filename = "certs/kube-controller-manager.pem"
}

module "kube-proxy" {
  source          = "./submodules/tls-cert-generator"
  cn              = "system:kube-proxy"
  org             = "system:node-proxier"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  validity_period = 8760
}

resource "local_file" "kube-proxy" {
    content     = module.kube-proxy.key
    filename = "certs/kube-proxy-key.pem"
}

resource "local_file" "kube-proxy-pem" {
    content     = module.kube-proxy.cert
    filename = "certs/kube-proxy.pem"
}

module "kube-scheduler" {
  source          = "./submodules/tls-cert-generator"
  cn              = "system:kube-scheduler"
  org             = "system:kube-scheduler"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  validity_period = 8760
}


resource "local_file" "kube-scheduler-key" {
    content     = module.kube-scheduler.key
    filename = "certs/kube-scheduler-key.pem"
}

resource "local_file" "kube-scheduler-pem" {
    content     = module.kube-scheduler.cert
    filename = "certs/kube-scheduler.pem"
}

module "service-account" {
  source          = "./submodules/tls-cert-generator"
  cn              = "service-accounts"
  org             = "Kubernetes"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  validity_period = 8760
}

resource "local_file" "service-account-key" {
    content     = module.service-account.key
    filename = "certs/service-account-key.pem"
}

resource "local_file" "service-account-pem" {
    content     = module.service-account.cert
    filename = "certs/service-account.pem"
}


module "kubernetes" {
  source          = "./submodules/tls-cert-generator"
  cn              = "kubernetes"
  org             = "Kubernetes"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  dns_names       = ["kubernetes","kubernetes.default","kubernetes.default.svc","kubernetes.default.svc.cluster","kubernetes.svc.cluster.local"]
  ip_addresses    = concat(["10.32.0.1", "127.0.0.1", google_compute_address.ip_address.address], google_compute_instance.controller.*.network_interface.0.network_ip)
  validity_period = 8760
}
resource "local_file" "kubernetes-key" {
    content = module.kubernetes.key
    filename = "certs/kubernetes-key.pem"
}

resource "local_file" "kubernetes-pem" {
    content = module.kubernetes.cert
    filename = "certs/kubernetes.pem"
}

module "worker-0" {
  source          = "./submodules/tls-cert-generator"
  cn              = "system:node:worker-0"
  org             = "system:nodes"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  ip_addresses    = [google_compute_instance.worker.*.network_interface.0.network_ip[0],google_compute_instance.worker.*.network_interface.0.access_config.0.nat_ip[0]]
  validity_period = 8760
}

resource "local_file" "worker-0" {
    content = module.worker-0.key
    filename = "certs/worker-0-key.pem"
}

resource "local_file" "worker-0-pem" {
    content = module.worker-0.cert
    filename = "certs/worker-0.pem"
}


module "worker-1" {
  source          = "./submodules/tls-cert-generator"
  cn              = "system:node:worker-1"
  org             = "system:nodes"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  ip_addresses    = [google_compute_instance.worker.*.network_interface.0.network_ip[1],google_compute_instance.worker.*.network_interface.0.access_config.0.nat_ip[1]]
  validity_period = 8760
}
resource "local_file" "worker-1" {
    content = module.worker-1.key
    filename = "certs/worker-1-key.pem"
}

resource "local_file" "worker-1-pem" {
    content = module.worker-1.cert
    filename = "certs/worker-1.pem"
}
module "worker-2" {
  source          = "./submodules/tls-cert-generator"
  cn              = "system:node:worker-2"
  org             = "system:nodes"
  ou              = var.cluster_name
  ca_cert         = module.init-ca.ca_cert
  ca_key          = module.init-ca.ca_key
  country         = "United Kindgom"
  location        = "London"
  ip_addresses    = [google_compute_instance.worker.*.network_interface.0.network_ip[2],google_compute_instance.worker.*.network_interface.0.access_config.0.nat_ip[2]]
  validity_period = 8760
}
resource "local_file" "worker-2" {
    content = module.worker-2.key
    filename = "certs/worker-2-key.pem"
}

resource "local_file" "worker-2-pem" {
    content = module.worker-2.cert
    filename = "certs/worker-2.pem"
}