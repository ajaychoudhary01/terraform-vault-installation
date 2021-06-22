resource "helm_release" "vault" {
  depends_on = [helm_release.consul]

  name       = "vault"
  namespace  = kubernetes_namespace.vault.metadata.0.name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.12.0"
}