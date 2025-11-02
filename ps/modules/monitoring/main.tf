resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace
  wait       = false
  timeout    = 900

  values = [
    yamlencode({
      grafana = {
        grafana = {
          ini = {
            server = {
              root_url            = "https://${var.grafana_domain}/monitoring"
              serve_from_sub_path = true
            }
          }
        }
        persistence = {
          enabled          = true
          size             = "10Gi"
          storageClassName = "local-path"
        }
      }

      prometheus = {
        enabled = true
        prometheusSpec = {
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "20Gi"
                  }
                }
                storageClassName = "local-path"
              }
            }
          }
          resources = {
            requests = {
              memory = "1Gi"
            }
          }
          retention = "15d"
        }
      }

      alertmanager = {
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                resources = {
                  requests = {
                    storage = "2Gi"
                  }
                }
              }
            }
          }
        }
      }
    })
  ]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = var.namespace
  wait       = false
  timeout    = 900

  values = [
    yamlencode({
      persistence = {
        enabled = false
      }

      tempo = {
        searchEnabled = true
        metricsGenerator = {
          enabled = true
          processor = {
            local_blocks = {
              filter_server_spans = false
              flush_to_storage    = true
            }
          }
        }
        overrides = {
          defaults = {
            metrics_generator = {
              processors = ["local-blocks"]
            }
          }
        }
      }
    })
  ]
}

