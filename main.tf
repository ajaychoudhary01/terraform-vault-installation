resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.namespace
  }
}

resource "random_id" "gossip_key" {
  byte_length = 32
}

#This is required by consul
resource "kubernetes_secret" "gossip_key" {
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
  depends_on = [kubernetes_secret.gossip_key]
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
