resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

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

resource "kubernetes_namespace" "tenant_system" {
  metadata {
    name = "tenant-system"
  }
}

resource "kubernetes_namespace" "secret_system" {
  metadata {
    name = "secret-system"
  }
}

resource "kubernetes_namespace" "tf_state" {
  metadata {
    name = "tf-state"
  }
}
