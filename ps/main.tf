terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
}

provider "kubernetes" {
  config_path = var.projectsprint_kubeconfig
}

# terraform import kubernetes_namespace.kube_system kube-system
resource "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
}

# terraform import kubernetes_namespace.capsule_system capsule-system
resource "kubernetes_namespace" "capsule_system" {
  metadata {
    name = "capsule-system"
  }
}

