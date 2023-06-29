variable "basename" {
  description = "Base name used for creating cloud resources"
  type        = string
}

variable "theme" {
  description = "The theme of the application"
  type        = string
}

variable "zone" {
  description = "The zone where the application will be deployed"
  type        = string
}

variable "region" {
  description = "The region where the application will be deployed"
  type        = string
}

variable "image" {
  description = "The image to be used for the application"
  type        = string
}

variable "ip_cidr_range" {
  description = "The IP CIDR range for the application"
  type        = string
}

variable "internal_port" {
  description = "Internal HTTP server port"
  type        = number
  default     = 8080
}

variable "grpc_allowlist" {
  description = "A list of CIDR ranges to allow to access the gRPC back-end"
  type        = list(any)
  default     = []
}
