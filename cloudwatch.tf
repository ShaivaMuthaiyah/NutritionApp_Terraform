

resource "aws_iam_role" "cloudwatch-agent" {
  count       = 1
  name        = "cloudwatch-agent"
  description = "IAM role used by the cloudwatch agent inside EKS clusters"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${aws_iam_openid_connect_provider.eks.url}:sub" = "sts.amazonaws.com"
            }
          }
          Effect = "Allow",
          Principal = {
            Federated = aws_iam_openid_connect_provider.eks.arn
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "cloudwatch-agent" {
  count = 1
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "cloudwatch:PutMetricData",
            "ec2:DescribeTags",
            "ec2:DescribeVolumeAttribute",
            "ec2:DescribeVolumes",
            "ec2:DescribeVolumeStatus",
            "eks:*",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cloudwatch-agent" {
  count      = 1
  role       = aws_iam_role.cloudwatch-agent[0].name
  policy_arn = aws_iam_policy.cloudwatch-agent[0].arn
}

# helm chart to deploy the cloudwatch agent
resource "helm_release" "cloudwatch-agent" {
  count      =  1
  name       = "cloudwatch"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-cloudwatch-metrics"
  version    = "0.0.10"


  values = [
    jsonencode({
      eks_cluster_name = var.cluster_name
      iam_role_arn     = aws_iam_role.cloudwatch-agent[0].arn
    })
  ]

  depends_on = [
      aws_eks_cluster.nutrition,
      data.aws_eks_cluster_auth.nutrition
    ]
}