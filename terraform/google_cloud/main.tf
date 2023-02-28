variable "project_name" {
  type = string
  default = "serious-citron-378115"
}

variable "port_number" {
  type = string
  default = "9090"
}

variable "docker_declaration" {
  type = string
  # Change the image: string to match the docker image you want to use
  default = "spec:\n  containers:\n    - name: test-docker\n      image: 'pant7/prometheus:latest'\n      stdin: false\n      tty: false\n  restartPolicy: Always\n"
}

variable "boot_image_name" {
  type = string
  default = "projects/cos-cloud/global/images/cos-stable-69-10895-62-0"
}

# Specify the provider (GCP, AWS, Azure)
provider "google"{
  credentials = file("../../../save/test.json")
  project = var.project_name
  region = "europe-north1-b"
}


data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_instance" "prom" {
  name = "prom"
  machine_type = "g1-small"
  zone = "europe-north1-b"
  tags =[
      "name","prom"
  ]

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.boot_image_name
      type = "pd-standard"
    }
  }

  metadata = {
    gce-container-declaration = var.docker_declaration
  }

  labels = {
    container-vm = "cos-stable-69-10895-62-0"
  }

  network_interface {
    network= "default"
    access_config {
      // Ephemeral IP
    }
  }
}

output "Public_IP_Address" {
  value = google_compute_instance.prom.network_interface[0].access_config[0].nat_ip
}


resource "google_compute_firewall" "http-9090" {
  name = "http-9090"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = [var.port_number]
  }
  source_ranges= ["0.0.0.0/0"]
}
