resource "helm_release" "capsule_proxy" {
  name       = "capsule-proxy"
  repository = "oci://ghcr.io/projectcapsule/charts"
  chart      = "capsule-proxy"
  namespace  = var.namespace
  wait       = false

  values = [
    yamlencode({
      serviceMonitor = {
        enabled   = true
        namespace = var.namespace
      }

      service = {
        type     = "NodePort"
        port     = 9001
        portName = "proxy"
        nodePort = var.nodeport
      }

      options = {
        enableSSL            = true
        generateCertificates = false # capsule proxy generate it's own certificate
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
    })
  ]
}

