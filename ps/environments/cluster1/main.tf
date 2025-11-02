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

# kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
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
      - "--tracing.otlp.grpc.endpoint=${module.monitoring.tempo_input_url}"
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


module "eso" {
  source = "../../modules/vault"

  namespace               = module.namespaces.secret_system_name
  vault_kv_path           = "secret/"
  vault_token             = "asdf"
  vault_token_secret_name = "vault-token"
  vault_token_secret_key  = "token"
}
/**
 apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-db-secret
  namespace: app
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend          # 👈 link to SecretStore
    kind: SecretStore
  target:
    name: db-secret              # 👈 name of the K8s Secret to create
  data:
    - secretKey: username        # 👈 key inside K8s Secret
      remoteRef:
        key: secret/data/app/db  # 👈 path in Vault
        property: username       # 👈 property inside Vault secret
    - secretKey: password
      remoteRef:
        key: secret/data/app/db
        property: password
 */

/**
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myservice
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: app
          image: myrepo/myservice:latest
          envFrom:
            - secretRef:
                name: db-secret   # <- This comes from ESO
 */

/**
envFromSecrets:
  - name: db-secret
{{- if .Values.envFromSecrets }}
envFrom:
  {{- range .Values.envFromSecrets }}
  - secretRef:
      name: {{ .name }}
  {{- end }}
{{- end }}
 */
