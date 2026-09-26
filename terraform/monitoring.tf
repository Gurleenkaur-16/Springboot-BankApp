resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  create_namespace = true

  depends_on = [
    aws_eks_cluster.gurleen_cluster,
    aws_eks_node_group.gurleen_nodes
  ]
}