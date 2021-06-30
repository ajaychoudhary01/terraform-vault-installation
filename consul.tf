resource "random_id" "gossip_key" {
  byte_length = 32
}

resource "kubernetes_secret" "gossip-key" {
  metadata {
    namespace = kubernetes_namespace.vault.metadata.0.name
    name      = "gossip-key"
  }

  data = {
    "gossip.key" = random_id.gossip_key.b64_std
  }

  type = "Opaque"
}

resource "helm_release" "consul" {
  depends_on = [kubernetes_secret.gossip-key]
  name       = "vault-backend"
  namespace  = kubernetes_namespace.vault.metadata.0.name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = "0.31.1"

  dynamic "set" {
    for_each = local.consul_values

    content {
      name  = set.key
      value = set.value
    }
  }
}