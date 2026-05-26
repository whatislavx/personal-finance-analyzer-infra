# Create argocd namespace
resource "kubernetes_namespace" "argocd" {
  count = var.enable_k8s_addons ? 1 : 0

  metadata {
    name = "argocd"
  }

  depends_on = [module.eks]
}

locals {
  argocd_admin_values = var.argocd_admin_password != "" ? {
    configs = {
      secret = {
        argocdServerAdminPassword = var.argocd_admin_password
      }
    }
  } : {}
}

# Install ArgoCD using Helm chart
resource "helm_release" "argocd" {
  count = var.enable_k8s_addons ? 1 : 0

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd[0].metadata[0].name
  version    = "9.5.15"

  wait    = true
  timeout = 600
  atomic  = true

  values = [jsonencode(merge({
    server = {
      insecure = true
      service = {
        type = "LoadBalancer"
      }
    }
  }, local.argocd_admin_values))]
  depends_on = [kubernetes_namespace.argocd]
}

resource "time_sleep" "argocd_crds_ready" {
  count = var.enable_k8s_addons ? 1 : 0

  create_duration = "30s"
  depends_on      = [helm_release.argocd]
}

# Deploy root ArgoCD Application
resource "kubernetes_manifest" "argocd_root_app" {
  count = var.enable_k8s_addons && var.enable_argocd_root_app ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "finflow-platform-root"
      namespace = kubernetes_namespace.argocd[0].metadata[0].name
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_repo_revision
        path           = "k8s"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace.argocd[0].metadata[0].name
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [time_sleep.argocd_crds_ready]
}
