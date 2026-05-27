output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd[0].metadata[0].name
}

output "argocd_enabled" {
  description = "Whether ArgoCD addons were enabled"
  value       = var.enable_k8s_addons
}

output "argocd_service_commands" {
  description = "Useful kubectl commands to fetch ArgoCD service info and password"
  value = var.enable_k8s_addons ? {
    get_lb_host  = "kubectl -n ${kubernetes_namespace.argocd[0].metadata[0].name} get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
    get_password = "kubectl -n ${kubernetes_namespace.argocd[0].metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
    port_forward = "kubectl port-forward -n ${kubernetes_namespace.argocd[0].metadata[0].name} svc/argocd-server 8080:443"
  } : null
}
