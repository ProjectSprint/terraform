terraform {
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
  config_path = var.kubeconfig
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig
  }
}

module "namespaces" {
  source = "../../modules/namespaces"
}

module "cert_manager" {
  source = "../../modules/cert-manager"
  email  = "admin@projectsprint.id"
}

module "certificates" {
  source      = "../../modules/certificates"
  namespace   = module.namespaces.monitoring_name
  domain      = local.grafana_domain
  issuer_name = module.cert_manager.issuer_name
  depends_on  = [module.cert_manager]
}

module "monitoring" {
  source          = "../../modules/monitoring"
  namespace       = module.namespaces.monitoring_name
  grafana_domain  = local.grafana_domain
  tls_secret_name = module.certificates.tls_secret_name
  depends_on      = [module.certificates]
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
