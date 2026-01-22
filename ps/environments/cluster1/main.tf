terraform {
  backend "kubernetes" {
    secret_suffix = "state"
    namespace     = "tf-state"
    config_path   = "~/.kube/ps.kubeconfig"
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
  config_path = "~/.kube/ps.kubeconfig"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/ps.kubeconfig"
  }
}

module "namespaces" {
  source     = "../../modules/namespaces"
  namespaces = local.namespaces
}

module "cert_manager" {
  source = "../../modules/cert-manager"
}

module "cert_manager_issuer" {
  source = "../../modules/cert-manager-issuer/"
  email  = "admin@projectsprint.id"
}

module "grafana_tls" {
  source      = "../../modules/tls-certificate"
  namespace   = local.namespaces.monitoring
  domain      = local.domains.grafana
  secret_name = "${local.domains.grafana}-tls"
  issuer_name = module.cert_manager_issuer.name
}

# kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
module "kube-prom-stack" {
  source         = "../../modules/kube-prom-stack"
  namespace      = local.namespaces.monitoring
  grafana_domain = local.domains.grafana
}

module "traefik_config" {
  source         = "../../modules/traefik-config"
  values_content = <<-EOT
    additionalArguments:
      - "--metrics.prometheus.addEntryPointsLabels=true"
      - "--metrics.prometheus.addRoutersLabels=true"
      - "--metrics.prometheus.addServicesLabels=true"
      - "--tracing=true"
      - "--tracing.otlp.grpc=true"
      - "--tracing.otlp.grpc.endpoint=${module.kube-prom-stack.tempo_input_url}"
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
  domain                  = local.domains.grafana
  service_namespace       = local.namespaces.monitoring
  service_tls_secret_name = module.grafana_tls.secret_name
  service_name            = module.kube-prom-stack.grafana_svc_name
  service_port            = 80
}

module "capsule" {
  source      = "../../modules/capsule"
  namespace   = local.namespaces.capsule_system
  user_groups = [local.tenant.user_group]
  domain_sans = [local.domains.capsule]
}

module "capsule_tenants" {
  source            = "../../modules/capsule-tenant"
  tenant_user_group = local.tenant.user_group
  namespace         = local.namespaces.tenant_system

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

# module "eso" {
#   source = "../../modules/vault"
#
#   namespace               = module.namespaces.secret_system_name
#   vault_kv_path           = "secret/"
#   vault_token             = "asdf"
#   vault_token_secret_name = "vault-token"
#   vault_token_secret_key  = "token"
# }
