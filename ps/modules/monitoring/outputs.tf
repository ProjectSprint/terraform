output "grafana_public_url" {
  value = "https://${var.grafana_domain}/monitoring"
}

output "tempo_input_url" {
  value = "tempo.${var.namespace}.svc.cluster.local:4317"
}

output "prometheus_url" {
  value = "kube-prometheus-stack-prometheus.${var.namespace}.svc.cluster.local:9090"
}

output "grafana_svc_name" {
  value = "kube-prometheus-stack-grafana"
}
