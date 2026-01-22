resource "kubernetes_manifest" "certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = var.secret_name
      namespace = var.namespace
    }
    spec = {
      secretName = var.secret_name
      dnsNames   = [var.domain]
      issuerRef = {
        name = var.issuer_name
        kind = "ClusterIssuer"
      }
    }
  }
}
