output "monitoring_name" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}
output "kube_system_name" {
  value = kubernetes_namespace.kube_system.metadata[0].name
}
output "capsule_system_name" {
  value = kubernetes_namespace.capsule_system.metadata[0].name
}
output "tenant_system_name" {
  value = kubernetes_namespace.tenant_system.metadata[0].name
}
output "secret_system_name" {
  value = kubernetes_namespace.secret_system.metadata[0].name
}
