terraform {
  backend "kubernetes" {
    secret_suffix = "state"
    namespace     = "tf-state"
    # in_cluster_config = true
    config_path = "~/.kube/ps.kubeconfig"
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
  }
}

provider "kubernetes" {
}

provider "helm" {
  kubernetes = {
  }
}

module "namespaces" {
  source = "../../modules/namespaces"
}

module "cert_manager" {
  source = "../../modules/cert-manager"
  email  = "admin@projectsprint.id"
}

module "grafana_tls" {
  source      = "../../modules/tls-certificate"
  namespace   = module.namespaces.monitoring_name
  domain      = local.grafana_domain
  secret_name = "${local.grafana_domain}-tls"
  issuer_name = module.cert_manager.issuer_name
}

module "monitoring" {
  source         = "../../modules/monitoring"
  namespace      = module.namespaces.monitoring_name
  grafana_domain = local.grafana_domain
}

module "traefik" {
  source         = "../../modules/traefik"
  values_content = <<-EOT
    additionalArguments:
      - "--metrics.prometheus.addEntryPointsLabels=true"
      - "--metrics.prometheus.addRoutersLabels=true"
      - "--metrics.prometheus.addServicesLabels=true"
      - "--tracing=true"
      - "--tracing.otlp.grpc=true"
      - "--tracing.otlp.grpc.endpoint=${module.monitoring.tempo_url}"
      - "--tracing.otlp.grpc.insecure=true"
      - "--tracing.serviceName=traefik"
      - "--tracing.sampleRate=1.0"
    # optional, if you want the traefik to stick to one node
    nodeSelector:
      kubernetes.io/hostname: psonprem1
  EOT
}

module "grafana_ingress" {
  source                  = "../../modules/ingress"
  domain                  = local.grafana_domain
  service_namespace       = module.namespaces.monitoring_name
  service_tls_secret_name = module.grafana_tls.secret_name
  service_name            = module.monitoring.grafana_svc_name
  service_port            = 80
}

module "capsule" {
  source      = "../../modules/capsule"
  namespace   = module.namespaces.capsule_system_name
  user_groups = [local.tenant_user_group]
  domain_sans = ["cluster1.projectsprint.id"]
}

module "capsule_tenants" {
  source            = "../../modules/capsule-tenant"
  tenant_user_group = local.tenant_user_group
  namespace         = module.namespaces.tenant_system_name

  teams = [
    {
      name = "team-a"
      resourceQuotas = {
        cpu    = "2"
        memory = "2Gi"
      }
      namespaceQuota = 2
    },
    {
      name = "team-b"
      resourceQuotas = {
        cpu    = "4"
        memory = "8Gi"
      }
      namespaceQuota = 2
    }
  ]
}
