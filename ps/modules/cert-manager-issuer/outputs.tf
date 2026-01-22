output "name" {
  value = kubernetes_manifest.letsencrypt_prod.manifest["metadata"]["name"]
}
