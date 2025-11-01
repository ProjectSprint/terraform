variable "namespace" {
  type        = string
  description = "Namespace for the certificate (e.g., monitoring)"
}

variable "domain" {
  type        = string
  description = "DNS name"
}

variable "secret_name" {
  type        = string
  description = "Secret name for the tls cert place"
}

variable "issuer_name" {
  type        = string
  description = "ClusterIssuer name to use for certificate"
}
