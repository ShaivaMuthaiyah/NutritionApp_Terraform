# Define an IAM Policy Resource
resource "aws_iam_policy" "load_balancer_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM Policy for the AWS Load Balancer Controller"

  # Directly include the JSON policy
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:*",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup",
        "ec2:CreateSecurityGroup",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:ModifySubnetAttribute",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:CreateVpcPeeringConnection",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:AcceptVpcPeeringConnection",
        "ec2:RejectVpcPeeringConnection",
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets",
        "route53:GetChange",
        "route53:ListHostedZonesByName",
        "route53:ListHostedZones",
        "route53:CreateHealthCheck",
        "route53:GetHealthCheck",
        "route53:ListHealthChecks",
        "route53:DeleteHealthCheck",
        "tag:GetResources",
        "tag:TagResources",
        "wafv2:AssociateWebACL",
        "wafv2:DisassociateWebACL",
        "wafv2:GetWebACL",
        "wafv2:ListWebACLs",
        "shield:CreateProtection",
        "shield:DeleteProtection",
        "shield:DescribeProtection",
        "shield:DescribeSubscription",
        "shield:ListProtections"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create a Service Account with the Policy
resource "aws_iam_role" "eks_service_account" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# IAM Role Assumption Policy for Kubernetes
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${output.oidc_provider_id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${var.aws_region}.amazonaws.com/id/${output.oidc_provider_id}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lb_policy_attach" {
  role       = aws_iam_role.eks_service_account.name
  policy_arn = aws_iam_policy.load_balancer_controller_policy.arn
}

# Define the Service Account Namespace
resource "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
}

# Map the Service Account to the Role
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = kubernetes_namespace.kube_system.metadata[0].name
  }

  automount_service_account_token = true
  depends_on                      = [aws_iam_role_policy_attachment.lb_policy_attach]
}
