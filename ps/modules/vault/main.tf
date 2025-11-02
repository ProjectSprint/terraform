# ---------------------------------------------------------------------
# Install the External Secrets Operator via Helm
# ---------------------------------------------------------------------
resource "helm_release" "external_secrets" {
  name       = var.release_name
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = var.namespace

  # Default values.yaml override (optional)
  values = [
    yamlencode({
      installCRDs    = true
      webhook        = { port = 10250 }
      serviceMonitor = { enabled = false }
    })
  ]
}

# ---------------------------------------------------------------------
# Create SecretStore that points to Vault
# ---------------------------------------------------------------------
resource "kubernetes_manifest" "vault_secretstore" {
  depends_on = [helm_release.external_secrets]
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name      = "vault-backend"
      namespace = var.namespace
    }
    spec = {
      provider = {
        vault = {
          server  = "https://vault.${var.namespace}.svc.cluster.local:8200"
          path    = var.vault_kv_path
          version = "v2"
          auth = {
            tokenSecretRef = {
              name = var.vault_token_secret_name
              key  = var.vault_token_secret_key
            }
          }
        }
      }
    }
  }
}

# ---------------------------------------------------------------------
# Optionally create Kubernetes Secret containing Vault token
# ---------------------------------------------------------------------
resource "kubernetes_secret" "vault_token" {
  count = var.create_vault_token_secret ? 1 : 0

  metadata {
    name      = var.vault_token_secret_name
    namespace = var.namespace
  }

  data = {
    (var.vault_token_secret_key) = base64encode(var.vault_token)
  }
}

