output "tls_secret_name" {
  value = kubernetes_manifest.grafana_certificate.manifest["spec"]["secretName"]
}
