resource "kubernetes_manifest" "grafana_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "grafana-tls"
      namespace = var.namespace
    }
    spec = {
      secretName = "${var.domain}-secret"
      dnsNames   = [var.domain]
      issuerRef = {
        name = var.issuer_name
        kind = "ClusterIssuer"
      }
    }
  }
}
