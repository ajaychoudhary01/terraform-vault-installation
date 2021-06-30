data "kubernetes_secret" "vault_auth_sa" {
  depends_on = [kubernetes_service_account.vault_auth]
  metadata {
    name = kubernetes_service_account.vault_auth.default_secret_name
    namespace = var.namespace
  }
}

data "vault_policy_document" "reader_policy" {
  rule {
    path = "secrets/myproject/*"
    capabilities = ["read"]
    description = "allow reading secrets from myproject applications"
  }
}

data "vault_policy_document" "cicd_policy" {
  rule {
    path = "secrets/myproject/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description = "allow create/delete permission to myproject ci/cd platform"
  }
}