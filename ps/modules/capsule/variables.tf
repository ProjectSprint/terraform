variable "namespace" {
  type        = string
  description = "Namespace where Capsule will be installed"
  default     = "capsule-system"
}

variable "domain_sans" {
  type        = list(string)
  description = "List of domains that needs to be included at capsule domain"
}

variable "user_groups" {
  type        = list(string)
  description = "grafana namespace name for monitoring"
}

variable "grafana_namespace" {
  type        = string
  description = "grafana namespace name for monitoring"
}

variable "prometheus_namespace" {
  type        = string
  description = "prometheus namespace name for service monitoring"
}

