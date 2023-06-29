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
| [google_compute_firewall.allow-hc-rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.expose-grpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_http_health_check.manifest-json](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | resource |
| [google_compute_instance.brv](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
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
