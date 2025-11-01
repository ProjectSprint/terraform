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

# resource "kubernetes_manifest" "argocd_certificate" {
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "Certificate"
#     metadata = {
#       name      = "argocd-server-tls"
#       namespace = "argocd"
#     }
#     spec = {
#       secretName = "argocd-server-tls"
#       dnsNames   = ["argocd-cluster1.projectsprint.id"]
#       issuerRef = {
#         name = var.issuer_name
#         kind = "ClusterIssuer"
#       }
#     }
#   }
# }
