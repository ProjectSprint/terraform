resource "kubernetes_manifest" "monitoring_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "monitoring-ingress"
      namespace = var.namespace
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "traefik.ingress.kubernetes.io/router.tls"         = "true"
      }
    }
    spec = {
      tls = [
        {
          hosts      = [var.grafana_domain]
          secretName = var.tls_secret_name
        }
      ]
      rules = [
        {
          host = var.grafana_domain
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "kube-prometheus-stack-grafana"
                    port = { number = 80 }
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

