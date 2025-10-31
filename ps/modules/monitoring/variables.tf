variable "namespace" {
  type        = string
  description = "Namespace for monitoring resources"
}

variable "grafana_domain" {
  type        = string
  description = "Domain name for Grafana"
}

variable "tls_secret_name" {
  type        = string
  description = "TLS secret for Grafana ingress"
}

