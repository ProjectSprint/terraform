variable "namespace" {
  type        = string
  description = "Namespace for the certificate (e.g., monitoring)"
}

variable "domain" {
  type        = string
  description = "DNS name"
}

variable "issuer_name" {
  type        = string
  description = "ClusterIssuer name to use for certificate"
}
