# Terraform module for deploying build-results-viewer to GCP

Copyright (c) 2023 [Antmicro](https://www.antmicro.com)

This module deploys a set of infrastructure resources that together comprise a self-hosted [Build Results Viewer](https://github.com/antmicro/build-results-viewer) instance.

## Running the container

The application is deployed as a Docker container
on a Compute Engine instance running [Container-Optimized OS](https://cloud.google.com/container-optimized-os/docs).
Please be advised that this module on its own does not handle deploying the container image;
this is something that you need to do separately after building the image using `bazel build -c opt server:build_results_viewer_container`.

If you're uploading the image to the [Artifact Registry](https://cloud.google.com/artifact-registry), you need to grant the app instance service account
the read permission to the repository or project-wide.
This may be accomplished by creating an IAM binding between the service account and the `roles/artifactregistry.reader` role.

## Exposing the front-end and back-end services

By default, the instance does not have any firewall rules for exposing the internal ports used by the application.

Some of the possible strategies for exposing the front-end (port 8080) service to the Internet include:
* Using the built-in [Caddy](https://caddyserver.com/) support by setting the `caddy_external_ip` and `caddy_domain` variables.
* Setting up a [Load Balancer](https://cloud.google.com/load-balancing?hl=en) that will act as a reverse proxy (SSL termination is possible).

In order to expose the internal backend (gRPC port 1985) to a GCP instance running within the same or a different project,
you can use [VPC Network Peering](https://cloud.google.com/vpc/docs/vpc-peering).
After doing this, make sure to populate the `grpc_allowlist` variable (e.g. `10.4.3.2/32` for a single instance) to allow ingress traffic to the service.

## Required permissions

In order to deploy the infrastructure, make sure that the service account has the following roles:

* **Compute Admin** for creating and managing resources within the Compute Engine.
* **Service Account Creator** for managing the service account linked with the coordinator instance.
* **Service Account User** for assigning the aforementioned service account to the coordinator instance.
* **Service Usage Admin** for enabling the necessary APIs.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.42.1 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 4.42.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.42.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.app-internal-ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_backend_service.brv-service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_disk.data-disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.allow-caddy-http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-caddy-https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-hc-rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.expose-grpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_http_health_check.manifest-json](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | resource |
| [google_compute_instance.brv](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.caddy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance_group.brv-group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_compute_network.network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.main-subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_project_service.compute-engine-api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.iam-api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_compute_image.coreos](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_basename"></a> [basename](#input\_basename) | Base name used for creating cloud resources | `string` | n/a | yes |
| <a name="input_caddy_domain"></a> [caddy\_domain](#input\_caddy\_domain) | (optional) Domain pointed at `caddy_external_ip` for SSL termination | `string` | `null` | no |
| <a name="input_caddy_external_ip"></a> [caddy\_external\_ip](#input\_caddy\_external\_ip) | (optional) Reserved external IP for the Internet-facing proxy | `string` | `null` | no |
| <a name="input_caddy_image"></a> [caddy\_image](#input\_caddy\_image) | (optional) Container image of Caddy reverse proxy | `string` | `"caddy"` | no |
| <a name="input_grpc_allowlist"></a> [grpc\_allowlist](#input\_grpc\_allowlist) | A list of CIDR ranges to allow to access the gRPC back-end | `list(any)` | `[]` | no |
| <a name="input_image"></a> [image](#input\_image) | The image to be used for the application | `string` | n/a | yes |
| <a name="input_internal_port"></a> [internal\_port](#input\_internal\_port) | Internal HTTP server port | `number` | `8080` | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | The IP CIDR range for the application | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where the application will be deployed | `string` | n/a | yes |
| <a name="input_theme"></a> [theme](#input\_theme) | The theme of the application | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone where the application will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_address"></a> [backend\_address](#output\_backend\_address) | The address and port of the app backend |
| <a name="output_sa"></a> [sa](#output\_sa) | The email address of the service account assigned to the Build Results Viewer instance |
