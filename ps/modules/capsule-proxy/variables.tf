variable "namespace" {
  type        = string
  description = "Namespace where Capsule will be installed"
  default     = "capsule-system"
}

variable "domain_sans" {
  type        = list(string)
  description = "List of domains that needs to be included at capsule domain"
}

variable "nodeport" {
  type        = number
  description = "The port to serve"
}
