resource "aws_iam_role" "nutrition" {
  name = "eks-cluster-nutrition"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "nutrition-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.nutrition.name
}



# resource "aws_iam_role_policy_attachment" "nutrition-AWSLoadBalancerControllerRolePolicyAttachment" {
#   role       = aws_iam_role.eks_service_account.name
#   policy_arn = aws_iam_policy.AWSLoadBalancerControllerPolicy.arn
# }

resource "aws_eks_cluster" "nutrition" {
  name     = "nutrition"
  role_arn = aws_iam_role.nutrition.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-ap-south-1a.id,
      aws_subnet.private-ap-south-1b.id,
      aws_subnet.public-ap-south-1a.id,
      aws_subnet.public-ap-south-1b.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nutrition-AmazonEKSClusterPolicy
    ]


    
}



output "cluster_name" {
   value = aws_eks_cluster.nutrition.name
 }