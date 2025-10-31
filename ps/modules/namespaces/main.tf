resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# terraform import 'module.namespaces.kubernetes_namespace.kube_system' 'kube-system'
resource "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
}

resource "kubernetes_namespace" "capsule_system" {
  metadata {
    name = "capsule-system"
  }
}
