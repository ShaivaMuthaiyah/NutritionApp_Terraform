resource "aws_eks_access_policy_association" "root_access" {

  cluster_name  = var.cluster_name
  principal_arn = var.root_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type       = "cluster"
  }

}



 # Access entry on the EKS cluster for the root user to access it
 resource "aws_eks_access_entry" "root_access_entry" {
  cluster_name      = var.cluster_name
  principal_arn     = var.root_arn
  kubernetes_groups = ["eks-admins", "system:masters"]
  type              = "STANDARD"
}