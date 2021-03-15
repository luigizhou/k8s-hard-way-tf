resource "random_string" "kube-encryption" {
  length  = 32
  special = false
}

data "template_file" "kube-encryption" {
  template = file("./templates/kube-encryption.yml.tpl")
  vars = {
    encryption_key = base64encode(random_string.kube-encryption.result)
  }
}

resource "local_file" "kube-encryption" {
    content = data.template_file.kube-encryption.rendered
    filename = "certs/encryption-config.yaml"
}

resource "google_compute_address" "ip_address" {
    name = "k8s-hard-way"
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh-key" {
    content     = tls_private_key.ssh-key.private_key_pem
    file_permission = 0600
    filename = "./ssh-key.pem"
}


resource "google_compute_instance" "controller" {
    count = 3
    name         = "controller-${count.index}"
    machine_type = "e2-medium"
    zone         = "europe-west1-b"
    can_ip_forward = "true"

    boot_disk {
        initialize_params {
        image = "ubuntu-2004-lts"
        }
    }

    network_interface {
        network = "k8s-hard-way"
        subnetwork = "k8s-hard-way"

        network_ip = "10.120.0.1${count.index}"

        access_config {
        // Ephemeral IP
        }
    }

    metadata = {
        ssh-keys = "terraform:${tls_private_key.ssh-key.public_key_openssh}"
    }
}

resource "null_resource" "cluster" {
    count = 3
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = join(",", google_compute_instance.controller.*.id)
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
      type = "ssh"
      user = "terraform"
      private_key = tls_private_key.ssh-key.private_key_pem
      host = element(google_compute_instance.controller.*.network_interface.0.access_config.0.nat_ip, count.index)
  }

  provisioner "file" {
    source = "certs/"
    destination = "/tmp/"
  }

  provisioner "file" {
    source = "bin/"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/etcd_bootstrap.sh",
      "/tmp/etcd_bootstrap.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/control_plane_bootstrap.sh",
      "/tmp/control_plane_bootstrap.sh"
    ]
  }
}

resource "null_resource" "rbac" {

  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = join(",", google_compute_instance.controller.*.id)
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
      type = "ssh"
      user = "terraform"
      private_key = tls_private_key.ssh-key.private_key_pem
      host = element(google_compute_instance.controller.*.network_interface.0.access_config.0.nat_ip, 0)
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/rbac.sh",
      "/tmp/rbac.sh"
    ]
  }
  depends_on = [
    null_resource.cluster
  ]
}

resource "google_compute_instance" "worker" {
    count = 3
    name         = "worker-${count.index}"
    machine_type = "e2-medium"
    zone         = "europe-west1-b"
    can_ip_forward = "true"

    boot_disk {
        initialize_params {
        image = "ubuntu-2004-lts"
        }
    }

    network_interface {
        network = "k8s-hard-way"
        subnetwork = "k8s-hard-way"

        access_config {
        // Ephemeral IP
        }
    }

    metadata = {
      "ssh-keys" = "terraform:${tls_private_key.ssh-key.public_key_openssh}"
      "pod-cidr" = "10.200.${count.index}.0/24"
    }

}

resource "null_resource" "workers" {
    count = 3
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = join(",", google_compute_instance.worker.*.id)
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
      type = "ssh"
      user = "terraform"
      private_key = tls_private_key.ssh-key.private_key_pem
      host = element(google_compute_instance.worker.*.network_interface.0.access_config.0.nat_ip, count.index)
  }

  provisioner "file" {
    source = "certs/"
    destination = "/tmp/"
  }

  provisioner "file" {
    source = "bin/"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/worker_bootstrap.sh",
      "/tmp/worker_bootstrap.sh"
    ]
  }
}