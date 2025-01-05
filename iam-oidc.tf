data "tls_certificate" "eks" {
  url = aws_eks_cluster.nutrition.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.nutrition.identity[0].oidc[0].issuer
}

output "oidc_provider_id" {
  value = aws_iam_openid_connect_provider.eks.id
  description = "The OIDC provider ID for the EKS cluster"
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
  description = "The OIDC provider URL for the EKS cluster"
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
  description = "The OIDC provider ARN for the EKS cluster"
}