locals {
  domains = {
    grafana = "grafana-cluster1.projectsprint.id"
    vault   = "vault-cluster1.projectsprint.id"
    capsule = "cluster1.projectsprint.id"
  }
  tenant = {
    user_group = "system:serviceaccounts:tenant-system"
  }
  namespaces = {
    monitoring     = "monitoring"
    kube_system    = "kube-system"
    capsule_system = "capsule-system"
    tenant_system  = "tenant-system"
    secret_system  = "secret-system"
    tf_state       = "tf-state"
  }
}

