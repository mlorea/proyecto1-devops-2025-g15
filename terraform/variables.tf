# Variables definidas en main.tf y monitoring.tf.
# Se inyectan desde GitHub Actions como TF_VAR_*.

variable "aws_region" {
  type = string
}

variable "image" {
  description = "URI completa de la imagen Docker en ECR (app todo)"
  type        = string
}

variable "prometheus_image" {
  description = "URI completa de la imagen Docker en ECR (prometheus)"
  type        = string
}

variable "alertmanager_image" {
  description = "URI completa de la imagen Docker en ECR (alertmanager)"
  type        = string
}

variable "grafana_image" {
  description = "URI completa de la imagen Docker en ECR (grafana)"
  type        = string
}

variable "ui_allowed_cidr" {
  type        = string
  description = "CIDR allowed to access Grafana/Prometheus/Alertmanager UIs"
  default     = "0.0.0.0/0"
}