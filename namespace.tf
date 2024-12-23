provider "kubernetes" {
  host                   = aws_eks_cluster.nutrition.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.nutrition.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.nutrition.token

}

data "aws_eks_cluster_auth" "nutrition" {
  name = aws_eks_cluster.nutrition.name
}

resource "kubernetes_namespace" "nutrition_namespace" {
  metadata {
    name = "nutrition"
  }
}