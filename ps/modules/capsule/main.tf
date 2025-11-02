resource "helm_release" "capsule" {
  name       = "capsule"
  repository = "oci://ghcr.io/projectcapsule/charts"
  chart      = "capsule"
  version    = "0.11.1"
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
      manager = {
        options = {
          forceTenantPrefix = true
          capsuleUserGroups = concat(
            [
              "projectcapsule.dev",
            ],
            var.user_groups
          )
        }
      }
      monitoring = {
        dashboards = {
          enabled   = true
          namespace = var.namespace
          operator = {
            # enable to make tenant can make their own delcarative grafana dashboard
            # note: Requres GrafanaDashboard CRD
            enabled = false
          }
        }
        serviceMonitor = {
          enabled   = true
          namespace = var.namespace
        }
      }
      proxy = {
        enabled = true
        serviceMonitor = {
          enabled   = true
          namespace = var.namespace
        }
        service = {
          type     = "NodePort"
          port     = 9001
          portName = "proxy"
          nodePort = 30443
        }
        options = {
          enableSSL            = true
          generateCertificates = false
          additionalSANs       = var.domain_sans
        }
        certManager = {
          generateCertificates = true
          externalCA = {
            enabled = false
          }
          certificate = {
            includeInternalServiceNames = true
            dnsNames                    = var.domain_sans
          }
        }
      }
    })
  ]
}

