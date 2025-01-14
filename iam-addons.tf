data "aws_eks_addon_version" "EBS_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.nutrition.version
  most_recent        = true
}



# IAM Role Assumption Policy for Kubernetes (Using the OIDC provider URL dynamically)
data "aws_iam_policy_document" "ebs_csi_driver_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn] 
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller"]
    }
  }
}


resource "aws_iam_role" "ebs_csi_driver" {

  description = "IAM Role used to provision EBS Volumes for the persistent volumes"
  name               = "ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role.json
}


resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}



# Map the Service Account to the Role
resource "kubernetes_service_account" "ebs-csi-controller" {
  metadata {
    name      = "ebs-csi-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver.arn
    }
  }

  automount_service_account_token = true

  depends_on                      = [aws_iam_role_policy_attachment.AmazonEBSCSIDriverPolicy, aws_eks_access_entry.terraform_user_access_entry]
}