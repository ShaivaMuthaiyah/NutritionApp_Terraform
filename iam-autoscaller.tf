

resource "aws_iam_policy" "ClusterAutoScalingControllerPolicy" {
  name = "ClusterAutoScalingControllerRolePolicy"

  policy = jsonencode({
    Statement = [{
      Action = [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}


module "iam_assumable_role_aws_autoscaling" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "ClusterAutoScalingControllerRole"
  provider_url                  = aws_iam_openid_connect_provider.eks.url
  role_policy_arns              = [aws_iam_policy.ClusterAutoScalingControllerPolicy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler"]

  tags = {
    Terraform   = "true"
  }

}


data "aws_iam_policy_document" "eks_cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole", "sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role" "eks_autoscaler_service_account" {
  description = "IAM Role used by the load balancer controller to add/remove nodes"
  name               = "EKSClusterAutoScalingControllerRole"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy.json
}


resource "aws_iam_role_policy_attachment" "ClusterAutoScalingControllerRolePolicyAttachment" {
  role       = aws_iam_role.eks_autoscaler_service_account.name
  policy_arn = aws_iam_policy.ClusterAutoScalingControllerPolicy.arn
}


# service account for the autoscaler to use in the clsuter
resource "kubernetes_service_account" "eks_cluster-autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_autoscaler_service_account.arn
    }
  }

  automount_service_account_token = true
  depends_on= [aws_iam_role_policy_attachment.ClusterAutoScalingControllerRolePolicyAttachment, aws_eks_access_entry.terraform_user_access_entry]
}


output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.eks_autoscaler_service_account.arn
}
