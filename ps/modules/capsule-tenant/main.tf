locals {
  # Convert list to map keyed by team name for for_each
  teams_map = { for t in var.teams : t.name => t }
}

resource "kubernetes_manifest" "tenant" {
  for_each = local.teams_map

  manifest = {
    apiVersion = "capsule.clastix.io/v1beta2"
    kind       = "Tenant"
    metadata = {
      name = each.value.name
      annotations = {
        "meta.helm.sh/release-name"      = "terraform-release"
        "meta.helm.sh/release-namespace" = "tenant-system"
      }
    }
    spec = {
      owners = [
        {
          name = "${var.tenant_user_group}:${each.value.name}-sa"
          kind = "ServiceAccount"
        }
      ]
      resourceQuotas = {
        items = [
          {
            hard = {
              "requests.cpu"    = each.value.resourceQuotas.cpu
              "requests.memory" = each.value.resourceQuotas.memory
              "limits.cpu"      = each.value.resourceQuotas.cpu
              "limits.memory"   = each.value.resourceQuotas.memory
            }
          }
        ]
      }
      namespaceOptions = {
        quota = each.value.namespaceQuota
        additionalMetadata = {
          labels = {
            createdBy = each.value.name
          }
        }
      }
      podOptions = {
        additionalMetadata = {
          labels = {
            createdBy = each.value.name
          }
        }
      }
      serviceOptions = {
        additionalMetadata = {
          labels = {
            createdBy = each.value.name
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "tenant_sa" {
  for_each = local.teams_map

  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "${each.value.name}-sa"
      namespace = var.namespace
      labels = {
        createdBy = each.value.name
        tenant    = each.value.name
      }
    }
  }
}

