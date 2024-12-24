data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.nutrition.name
}

data "aws_arn" "root" {
  arn = var.root_arn
}

# resource "null_resource" "aws_auth_configmap" {
#   provisioner "local-exec" {
#     command = <<EOT
#       kubectl patch configmap aws-auth -n kube-system --patch '{
#         "mapUsers": [
#           {
#             "userarn": "${data.aws_arn.root.arn}",
#             "username": "admin",
#             "groups": ["system:masters"]
#           }
#         ]
#       }'
#     EOT
#   }

  # Explicit dependency to ensure cluster is ready
#   depends_on = [
#     aws_eks_cluster.nutrition
#   ]
# }
