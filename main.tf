data "google_project" "project" {}

locals {
  data_disk_name = "${var.basename}--data"
  spec = {
    spec = {
      containers = [
        {
          image = var.image
          env = [
            {
              name  = "BUILD_RESULTS_VIEWER_THEME"
              value = var.theme
            },
            {
              name  = "BUILD_RESULTS_VIEWER_CONFIG"
              value = "config/brv.prod.yaml"
            }
          ]
          volumeMounts = [
            {
              name      = local.data_disk_name
              mountPath = "/data"
              readOnly  = false
            }
          ]
        }
      ]
      volumes = [
        {
          name = local.data_disk_name
          gcePersistentDisk = {
            pdName   = local.data_disk_name
            fsType   = "ext4"
            readOnly = false
          }
        }
      ]
      restartPolicy = "Always"
    }
  }
  spec_as_yaml = yamlencode(local.spec)
  hc-tag       = "allow-brv-hc"
  brv-grpc-tag = "allow-brv-grpc"
  backend_port = 1985
}

resource "google_project_service" "compute-engine-api" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "iam-api" {
  service = "iam.googleapis.com"
}

resource "google_compute_network" "network" {
  name                    = "${var.basename}--net"
  auto_create_subnetworks = false
  depends_on = [
    google_project_service.compute-engine-api
  ]
}

resource "google_compute_subnetwork" "main-subnet" {
  name          = "${var.basename}--main-subnet"
  network       = google_compute_network.network.id
  region        = var.region
  ip_cidr_range = var.ip_cidr_range

  stack_type = "IPV4_ONLY"
}

resource "google_compute_firewall" "allow-hc-rule" {
  name          = "allow-hc--${var.basename}"
  direction     = "INGRESS"
  network       = google_compute_network.network.self_link
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = [local.hc-tag]

  allow {
    ports    = [var.internal_port]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "expose-grpc" {
  name          = "expose-grpc--${var.basename}"
  direction     = "INGRESS"
  network       = google_compute_network.network.self_link
  source_ranges = var.grpc_allowlist
  target_tags   = [local.brv-grpc-tag]

  allow {
    ports    = [local.backend_port]
    protocol = "tcp"
  }
}

resource "google_compute_address" "app-internal-ip" {
  name         = "${var.basename}--internal"
  subnetwork   = google_compute_subnetwork.main-subnet.id
  address_type = "INTERNAL"
  address      = cidrhost(var.ip_cidr_range, 2)
  region       = var.region
}

resource "google_service_account" "sa" {
  account_id   = "brv-${var.basename}"
  display_name = "SA for BRV instance"
  depends_on = [
    google_project_service.iam-api
  ]
}

resource "google_compute_disk" "data-disk" {
  name = local.data_disk_name
  size = 30
  zone = var.zone
  depends_on = [
    google_project_service.compute-engine-api
  ]
}

data "google_compute_image" "coreos" {
  family  = "cos-stable"
  project = "cos-cloud"
}

resource "google_compute_instance" "brv" {
  name         = var.basename
  zone         = var.zone
  machine_type = "e2-medium"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    initialize_params {
      type  = "pd-standard"
      image = "projects/cos-cloud/global/images/family/cos-stable"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.network.id
    network_ip = google_compute_address.app-internal-ip.address
    subnetwork = google_compute_subnetwork.main-subnet.id

    access_config {}
  }

  service_account {
    email = google_service_account.sa.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata = {
    gce-container-declaration = local.spec_as_yaml
  }

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }

  attached_disk {
    device_name = local.data_disk_name
    source      = google_compute_disk.data-disk.id
    mode        = "READ_WRITE"
  }

  labels = {
    container-vm = data.google_compute_image.coreos.name
  }

  tags = [
    local.hc-tag,
    local.brv-grpc-tag
  ]
}

resource "google_compute_instance_group" "brv-group" {
  name      = "${var.basename}--group"
  zone      = var.zone
  instances = [google_compute_instance.brv.self_link]

  named_port {
    name = "http"
    port = var.internal_port
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_http_health_check" "manifest-json" {
  name         = "${var.basename}-hc"
  port         = var.internal_port
  request_path = "/results/favicon/manifest.json"
}

resource "google_compute_backend_service" "brv-service" {
  name                  = "${var.basename}--service"
  port_name             = "http"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_instance_group.brv-group.id
  }

  health_checks = [
    google_compute_http_health_check.manifest-json.id
  ]
}

output "sa" {
  value       = google_service_account.sa.email
  description = "The email address of the service account assigned to the Build Results Viewer instance"
}

output "backend_address" {
  value       = "${google_compute_address.app-internal-ip.address}:${local.backend_port}"
  description = "The address and port of the app backend"
}
