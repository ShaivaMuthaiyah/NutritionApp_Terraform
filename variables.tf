# variables.tf
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "root_arn" {
  description = "AWS Root User ARN"
  type        = string
  sensitive   = true
}


variable "aws_region" {
  default = "ap-south-1"
  type        = string
}


variable "terraform_user_id" {

  type        = string
  sensitive   = true
}


variable "k8s_namespace" {
  description = "The Kubernetes namespace"
  type        = string
  default     = "kube-system"
}

variable "k8s_service_account" {
  description = "The Kubernetes service account"
  type        = string
  default     = "aws-load-balancer-controller"
}


variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = "nutrition"
}


# variable "aws_session_token" {
#   description = "AWS Session Token (Optional)"
#   type        = string
#   sensitive   = true
#   default     = null
# }
