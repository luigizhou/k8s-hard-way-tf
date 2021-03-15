data "template_file" "kube-controller-manager" {
  template = file("./templates/kubeconfig.yml.tpl")
  vars = {
    project_name = "kubernetes-the-hard-way"
    client_cert  = base64encode(module.kube-controller-manager.cert)
    client_key   = base64encode(module.kube-controller-manager.key)
    ca_cert      = base64encode(module.init-ca.ca_cert)
    user         = "system:kube-controller-manager"
    kube_address = "https://127.0.0.1:6443"
  }
}

resource "local_file" "kube-controller-manager-kubeconfig" {
    content = data.template_file.kube-controller-manager.rendered
    filename = "certs/kube-controller-manager.kubeconfig"
}

data "template_file" "kube-proxy" {
  template = file("./templates/kubeconfig.yml.tpl")
  vars = {
    project_name = "kubernetes-the-hard-way"
    client_cert  = base64encode(module.kube-proxy.cert)
    client_key   = base64encode(module.kube-proxy.key)
    ca_cert      = base64encode(module.init-ca.ca_cert)
    user         = "system:kube-proxy"
    kube_address = "https://${google_compute_address.ip_address.address}:6443"
  }
}

resource "local_file" "kube-proxy-kubeconfig" {
    content = data.template_file.kube-proxy.rendered
    filename = "certs/kube-proxy.kubeconfig"
}

data "template_file" "kube-scheduler" {
  template = file("./templates/kubeconfig.yml.tpl")
  vars = {
    project_name = "kubernetes-the-hard-way"
    client_cert  = base64encode(module.kube-scheduler.cert)
    client_key   = base64encode(module.kube-scheduler.key)
    ca_cert      = base64encode(module.init-ca.ca_cert)
    user         = "system:kube-scheduler"
    kube_address = "https://127.0.0.1:6443"
  }
}

resource "local_file" "kube-scheduler-kubeconfig" {
    content = data.template_file.kube-scheduler.rendered
    filename = "certs/kube-scheduler.kubeconfig"
}

data "template_file" "admin" {
  template = file("./templates/kubeconfig.yml.tpl")
  vars = {
    project_name = "kubernetes-the-hard-way"
    client_cert  = base64encode(module.admin.cert)
    client_key   = base64encode(module.admin.key)
    ca_cert      = base64encode(module.init-ca.ca_cert)
    user         = "admin"
    kube_address = "https://127.0.0.1:6443"
  }
}

resource "local_file" "admin-kubeconfig" {
    content = data.template_file.admin.rendered
    filename = "certs/admin.kubeconfig"
}

data "template_file" "admin-local" {
  template = file("./templates/kubeconfig.yml.tpl")
  vars = {
    project_name = "kubernetes-the-hard-way"
    client_cert  = base64encode(module.admin.cert)
    client_key   = base64encode(module.admin.key)
    ca_cert      = base64encode(module.init-ca.ca_cert)
    user         = "admin"
    kube_address = "https://${google_compute_address.ip_address.address}:6443"
  }
}

resource "local_file" "admin-local-kubeconfig" {
    content = data.template_file.admin-local.rendered
    filename = "admin.kubeconfig"
}

data "template_file" "worker-0" {
  template = file("./templates/kubeconfig.yml.tpl")
  vars = {
    project_name = "kubernetes-the-hard-way"
    client_cert  = base64encode(module.worker-0.cert)
    client_key   = base64encode(module.worker-0.key)
    ca_cert      = base64encode(module.init-ca.ca_cert)
    user         = "system:node:worker-0"
    kube_address = "https://${google_compute_address.ip_address.address}:6443"
  }
}

resource "local_file" "worker-0-kubeconfig" {
    content = data.template_file.worker-0.rendered
    filename = "certs/worker-0.kubeconfig"
}

data "template_file" "worker-1" {
  template = file("./templates/kubeconfig.yml.tpl")
  vars = {
    project_name = "kubernetes-the-hard-way"
    client_cert  = base64encode(module.worker-1.cert)
    client_key   = base64encode(module.worker-1.key)
    ca_cert      = base64encode(module.init-ca.ca_cert)
    user         = "system:node:worker-1"
    kube_address = "https://${google_compute_address.ip_address.address}:6443"
  }
}

resource "local_file" "worker-1-kubeconfig" {
    content = data.template_file.worker-1.rendered
    filename = "certs/worker-1.kubeconfig"
}

data "template_file" "worker-2" {
  template = file("./templates/kubeconfig.yml.tpl")
  vars = {
    project_name = "kubernetes-the-hard-way"
    client_cert  = base64encode(module.worker-2.cert)
    client_key   = base64encode(module.worker-2.key)
    ca_cert      = base64encode(module.init-ca.ca_cert)
    user         = "system:node:worker-2"
    kube_address = "https://${google_compute_address.ip_address.address}:6443"
  }
}

resource "local_file" "worker-2-kubeconfig" {
    content = data.template_file.worker-2.rendered
    filename = "certs/worker-2.kubeconfig"
}