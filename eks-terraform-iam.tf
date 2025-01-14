resource "aws_eks_access_policy_association" "terraform_user_access" {

  cluster_name  = var.cluster_name
  principal_arn = var.terraform_user_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type       = "cluster"
  }

  depends_on = [aws_eks_cluster.nutrition]

}



 # Access entry on the EKS cluster for the root user to access it
 resource "aws_eks_access_entry" "terraform_user_access_entry" {
  cluster_name      = var.cluster_name
  principal_arn     = var.terraform_user_arn
  kubernetes_groups = ["eks-admins"]
  type              = "STANDARD"
  depends_on = [aws_eks_cluster.nutrition]
}