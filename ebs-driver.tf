resource "aws_eks_addon" "EBS_driver" {

  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  addon_version               = data.aws_eks_addon_version.EBS_driver.version
  configuration_values        = null
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = null

  depends_on = [
    aws_eks_node_group.private-nodes
  ]

}