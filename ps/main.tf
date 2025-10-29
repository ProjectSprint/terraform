terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.projectsprint_kubeconfig
}

provider "helm" {
  kubernetes {
    config_path = var.projectsprint_kubeconfig
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "oci://quay.io/jetstack/charts"
  chart      = "cert-manager"
  namespace  = "cert-manager"

  create_namespace = true

  set {
    name  = "crds.enabled"
    value = true
  }
}

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Equivalent to: --set persistence.enabled=false
  set {
    name  = "persistence.enabled"
    value = false
  }

  # Equivalent to: --set tempo.searchEnabled=true
  set {
    name  = "tempo.searchEnabled"
    value = true
  }

  # Equivalent to: --set tempo.metricsGenerator.enabled=true
  set {
    name  = "tempo.metricsGenerator.enabled"
    value = true
  }

  # Equivalent to: --set tempo.overrides.defaults.metrics_generator.processors[0]=local-blocks
  set {
    name  = "tempo.overrides.defaults.metrics_generator.processors[0]"
    value = "local-blocks"
  }

  # Equivalent to: --set tempo.metricsGenerator.processor.local_blocks.filter_server_spans=false
  set {
    name  = "tempo.metricsGenerator.processor.local_blocks.filter_server_spans"
    value = false
  }

  # Equivalent to: --set tempo.metricsGenerator.processor.local_blocks.flush_to_storage=true
  set {
    name  = "tempo.metricsGenerator.processor.local_blocks.flush_to_storage"
    value = true
  }
}

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

