resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace
  wait       = false
  timeout    = 900

  set = [
    {
      name  = "grafana.grafana\\.ini.server.root_url"
      value = "https://${var.grafana_domain}/monitoring"
    },
    {
      name  = "grafana.grafana\\.ini.server.serve_from_sub_path"
      value = true
    },
    {
      name  = "grafana.persistence.enabled"
      value = "true"
    },
    {
      name  = "grafana.persistence.size"
      value = "10Gi"
    },
    {
      name  = "grafana.persistence.storageClassName"
      value = "local-path"
    },
    {
      name  = "grafana.grafana.ini.server.serve_from_sub_path"
      value = "true"
    },
    {
      name  = "prometheus.enabled"
      value = "true"
    },
    {
      name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
      value = "ReadWriteOnce"
    },
    {
      name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
      value = "20Gi"
    },
    {
      name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
      value = "local-path"
    },
    {
      name  = "prometheus.prometheusSpec.resources.requests.memory"
      value = "1Gi"
    },
    {
      name  = "prometheus.prometheusSpec.retention"
      value = "15d"
    },
    {
      name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage"
      value = "2Gi"
  }]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = var.namespace
  wait       = false
  timeout    = 900

  set = [
    {
      name  = "persistence.enabled"
      value = false
    },
    {
      name  = "tempo.searchEnabled"
      value = true
    },
    {
      name  = "tempo.metricsGenerator.enabled"
      value = true
    },
    {
      name  = "tempo.overrides.defaults.metrics_generator.processors[0]"
      value = "local-blocks"
    },
    {
      name  = "tempo.metricsGenerator.processor.local_blocks.filter_server_spans"
      value = false
    },
    {
      name  = "tempo.metricsGenerator.processor.local_blocks.flush_to_storage"
      value = true
  }]
}
