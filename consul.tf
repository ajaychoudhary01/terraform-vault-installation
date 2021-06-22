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

  #Keep these two values higher or default to 3, it is a daemon set (value should be <= number of nodes available)
  set {
    name  = "server.replicas"
    value = "1"
  }

  set {
    name  = "server.bootstrapExpect"
    value = "1"
  }
}