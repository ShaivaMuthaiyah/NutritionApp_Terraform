resource "aws_iam_policy" "alb_ingress_controller" {
  name = "alb-ingress-controller-policy"

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "elasticloadbalancing:*",  # Allows the ALB Controller to manage load balancers
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeRegions",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:CreateVpcLink"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role" "alb_ingress_controller_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  name = "alb-ingress-controller-role"
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_attach_policy" {
  policy_arn = aws_iam_policy.alb_ingress_controller.arn
  role       = aws_iam_role.alb_ingress_controller_role.name
}
