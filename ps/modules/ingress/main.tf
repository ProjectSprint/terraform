resource "kubernetes_manifest" "ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "${var.service_namespace}-${var.service_name}"
      namespace = var.service_namespace
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "traefik.ingress.kubernetes.io/router.tls"         = "true"
      }
    }
    spec = {
      tls = [
        {
          hosts      = [var.domain]
          secretName = var.service_tls_secret_name
        }
      ]
      rules = [
        {
          host = var.domain
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = var.service_name
                    port = { number = var.service_port }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}

