resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "vault" {
  depends_on = [helm_release.consul]

  name       = "vault"
  namespace  = kubernetes_namespace.vault.metadata.0.name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.12.0"

  dynamic "set" {
    for_each = local.vault_values

    content {
      name  = set.key
      value = set.value
    }
  }
}