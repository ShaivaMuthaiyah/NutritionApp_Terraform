resource "kubernetes_namespace" "nutrition_namespace" {
  metadata {
    name = "nutrition"
  }

  depends_on = [aws_eks_cluster.nutrition, aws_eks_access_entry.terraform_user_access_entry]
}