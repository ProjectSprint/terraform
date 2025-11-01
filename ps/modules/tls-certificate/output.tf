output "secret_name" {
  value = kubernetes_manifest.certificate.manifest["spec"]["secretName"]
}
