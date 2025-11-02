# output "secretstore_name" {
#   value = kubernetes_manifest.vault_secretstore.manifest.metadata.name
# }

output "namespace" {
  value = var.namespace
}

