provider "google" {
    credentials = "${file(var.credential_file)}"
    project = var.project_id
    region = var.region
    zone = var.zone
}

resource "google_project_service" "enabledeploymentmanagerapi" {
  project = var.project_id
  service = "deploymentmanager.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enablecloudresourcemanagerapi" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
}


data "google_compute_image" "debian" {
    family = "debian-9"
    project = "debian-cloud"
}

data "template_file" "nginx" {
    template = "${file("${path.module}/template/install_nginx.tpl")}"

    vars = {
        ufw_allow_nginx = "Nginx HTTP"
    }
}

data "template_file" "apache" {
    template = "${file("${path.module}/template/install_apache.tpl")}"
}

#resource "google_compute_address" "static" {
#    name = "ipv4-address"
#}

resource "google_compute_instance" "vm_instance" {
    name = var.name
    machine_type = var.machine_type
    description = "testing terraform IaC"
    zone = var.zone
    tags = ["http-server"]

    boot_disk {
    initialize_params {
        image = data.google_compute_image.debian.self_link
        }
    }

    network_interface {
        # A default network is created for all GCP projects
        network = "default"
        access_config {
            #nat_ip = google_compute_address.static.address
        }
    }

    metadata_startup_script = data.template_file.apache.rendered
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

output "webserver_internal_ip" {
    value = google_compute_instance.vm_instance.network_interface[0].network_ip
}

output "webserver_external_ip" {
    value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}

output "lb_ip" {
  value = kubernetes_service.createservice.load_balancer_ingress[0].ip
}