resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.namespace
  }
}

locals {
  release_name = "vault"
}