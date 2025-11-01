data "http" "argocd_manifest" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}

resource "kubernetes_manifest" "argocd" {
  for_each = { for idx, doc in yamldecode(data.http.argocd_manifest.body) : idx => doc }

  manifest = each.value
}
