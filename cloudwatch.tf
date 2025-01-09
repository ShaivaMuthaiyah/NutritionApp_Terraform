module "cloudwatch-agent" {
  source  = "bailey84j/cloudwatch-agent/kubernetes"
  version = "1.0.1"
  name = "nutrition-cloudwatch"

  create_namespace = false
  namespace = "kube-system"
  eks_cluster_name = aws_eks_cluster.nutrition.name

    tags = {
    Target = "Nutrition Cluster"
  }

  depends_on = [aws_eks_cluster.nutrition]

  # insert the 4 required variables here
}