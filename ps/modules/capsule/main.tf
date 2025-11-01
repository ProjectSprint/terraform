resource "helm_release" "capsule" {
  name       = "capsule"
  repository = "oci://ghcr.io/projectcapsule/charts"
  chart      = "capsule"
  namespace  = var.namespace
  wait       = false

  values = [
    yamlencode({
      certManager = {
        generateCertificates = true
        additionalSANS       = var.domain_sans
      }

      tls = {
        enableController = false
        create           = false
      }

      options = {
        forceTenantPrefix = true
        capsuleUserGroups = concat(
          [
            "projectcapsule.dev",
          ],
          var.user_groups
        )
      }

      monitoring = {
        dashboards = {
          enabled   = true
          namespace = var.grafana_namespace
          operator = {
            enabled = true
          }
        }
        serviceMonitor = {
          enabled   = true
          namespace = var.prometheus_namespace
        }
      }
    })
  ]
}

