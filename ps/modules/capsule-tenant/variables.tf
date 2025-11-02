variable "teams" {
  type = list(object({
    name = string
    resourceQuotas = object({
      cpu    = string
      memory = string
    })
    namespaceQuota = number
  }))
}

variable "namespace" {
  type = string
}

variable "tenant_user_group" {
  type = string
}
