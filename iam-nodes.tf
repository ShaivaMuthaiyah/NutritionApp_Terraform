resource "aws_iam_role" "eks_worker_node_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Service = "ec2.amazonaws.com"
          
        }
      }
    ]
  })
  
  name = "eks-worker-node-role"
}

resource "aws_iam_policy" "alb_ingress_policy" {
  name        = "ALBIngressPolicy"
  description = "Policy to manage ALB Ingress Controller resources"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
        
          "ec2:DescribeInstances",
          "ec2:*",
          "sts:*",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLoadBalancers",
          "ec2:DescribeTargetGroups",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "acm:ListCertificates", 
          "acm:DescribeCertificate" 
        ]
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_role_attachment" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = aws_iam_policy.alb_ingress_policy.arn
}
