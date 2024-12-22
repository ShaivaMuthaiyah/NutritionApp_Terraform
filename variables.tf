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


variable "aws_region" {
  default = "ap-south-1"
  type        = string
}

# variable "aws_session_token" {
#   description = "AWS Session Token (Optional)"
#   type        = string
#   sensitive   = true
#   default     = null
# }
