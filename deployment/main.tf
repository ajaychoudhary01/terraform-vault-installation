resource "kubernetes_service_account" "app" {
  metadata {
    name      = "vault-auth"
    namespace =  kubernetes_namespace.app.metadata[0].name
  }

  automount_service_account_token = true
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "vault-test-app"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      name = "vault-test-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        name = "vault-test-app"
      }
    }

    template {
      metadata {
        labels = {
          name = "vault-test-app"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject": "true"
          "vault.hashicorp.com/agent-inject-secret-mydbpassword": "secrets/myproject/dbpassword"
          "vault.hashicorp.com/role": "app-reader"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.app.metadata[0].name
        container {
          image = "nginx:1.7.8"
          name  = "vault-test-app"
        }
      }
    }
  }
}
