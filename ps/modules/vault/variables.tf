variable "namespace" {
  description = "Namespace to deploy ESO into"
  type        = string
  default     = "external-secrets"
}

variable "release_name" {
  description = "Helm release name for ESO"
  type        = string
  default     = "external-secrets"
}

variable "vault_kv_path" {
  description = "Path to Vault KV backend (e.g. secret/)"
  type        = string
  default     = "secret/"
}

variable "vault_token" {
  description = "Vault token used for auth"
  type        = string
  sensitive   = true
}

variable "vault_token_secret_name" {
  description = "Kubernetes secret name that stores the Vault token"
  type        = string
  default     = "vault-token"
}

variable "vault_token_secret_key" {
  description = "Key inside the Vault token secret"
  type        = string
  default     = "token"
}

variable "create_vault_token_secret" {
  description = "Whether to create the vault token secret automatically"
  type        = bool
  default     = true
}

