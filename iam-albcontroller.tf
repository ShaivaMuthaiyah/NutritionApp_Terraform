# Data resource to get the current AWS account id
data "aws_caller_identity" "current" {}



# locals {
#   iam_policy = file("iam-policy.json")
# }


# # Define IAM Policy Resource
# resource "aws_iam_policy" "load_balancer_controller_policy" {
#   name        = "AWSLoadBalancerControllerIAMPolicy"
#   description = "IAM Policy for the AWS Load Balancer Controller"
#   policy      = local.iam_policy
# }


resource "aws_iam_policy" "AWSLoadBalancerControllerPolicy" {
  name        = "AWSLoadBalancerControllerPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller Policy"


  policy = file("iam-policy.json")

  tags = {
    Terraform   = "true"

  }

}


module "iam_assumable_role_aws_lb" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "AWSLoadBalancerControllerRole"
  provider_url                  = aws_iam_openid_connect_provider.eks.url
  role_policy_arns              = [aws_iam_policy.AWSLoadBalancerControllerPolicy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]

  tags = {
    Terraform   = "true"
  }

}



# IAM Role Assumption Policy for Kubernetes (Using the OIDC provider URL dynamically)
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn] # Ensure correct ARN
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}


# Create IAM Role for the Load Balancer Controller with the policy attached
resource "aws_iam_role" "eks_service_account" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Attach Policy to Role
# resource "aws_iam_role_policy_attachment" "lb_policy_attach" {
#   role       = aws_iam_role.eks_service_account.name
#   policy_arn = aws_iam_policy.load_balancer_controller_policy.arn
# }


resource "aws_iam_role_policy_attachment" "AWSLoadBalancerControllerRolePolicyAttachment" {
  role       = aws_iam_role.eks_service_account.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerPolicy.arn
}

# Map the Service Account to the Role
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_service_account.arn
    }
  }

  automount_service_account_token = true
  # depends_on                      = [aws_iam_role_policy_attachment.lb_policy_attach]
  depends_on                      = [aws_iam_role_policy_attachment.AWSLoadBalancerControllerRolePolicyAttachment]
}
