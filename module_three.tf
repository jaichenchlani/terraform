provider "google" {
    credentials = "${file(var.credential_file)}"
    project = var.project_id
    region = var.region
    zone = var.zone
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
        network = "${google_compute_network.vpc_network.self_link}"
        #access_config = {
        #}
    }

    metadata_startup_script = data.template_file.nginx.rendered
}

resource "google_compute_network" "vpc_network" {
    name = "terraform-network"
    auto_create_subnetworks = "true"
}

output "webserver_internal_ip" {
    value = google_compute_instance.vm_instance.network_interface[0].network_ip
}