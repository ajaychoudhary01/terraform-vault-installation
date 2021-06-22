resource "kubernetes_service_account" "vault_auth" {
  metadata {
    name = "vault-auth"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
  automount_service_account_token = "true"
}

resource "kubernetes_cluster_role_binding" "vault_auth_role_binding" {
  metadata { 
    name = "role-tokenreview-binding" 
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "system:auth-delegator"
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.vault_auth.metadata[0].name
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
}

resource "vault_policy" "reader_policy" {
  name = "reader"
  policy = data.vault_policy_document.reader_policy.hcl
}

resource "vault_policy" "cicd_policy" {
  name = "cicd"
  policy = data.vault_policy_document.cicd_policy.hcl
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "config" {
  backend = vault_auth_backend.kubernetes.path
  kubernetes_host = data.aws_eks_cluster.this.endpoint
  kubernetes_ca_cert = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token_reviewer_jwt = data.kubernetes_secret.vault_auth_sa.data.token
}

resource "vault_kubernetes_auth_backend_role" "role" {
  backend = "kubernetes"
  role_name = "app-reader"
  bound_service_account_names = [kubernetes_service_account.vault_auth.metadata.0.name]
  bound_service_account_namespaces = ["*"] // Allow for all namespaces
  token_ttl = 43200 //1 day
  token_policies = [vault_policy.reader_policy.name]
}