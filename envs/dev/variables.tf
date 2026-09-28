variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name, used in resource names and tags."
  type        = string
  default     = "dc-demo"
}

variable "environment" {
  description = "Environment name, used in resource names and tags."
  type        = string
  default     = "dev"
}

# --- IAM ---------------------------------------------------------------------
variable "iam_users" {
  description = "IAM users to create and the groups (admins/developers) they belong to."
  type = map(object({
    groups = list(string)
  }))
  default = {}
}

# --- Network / EC2 -----------------------------------------------------------
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "create_ec2" {
  type    = bool
  default = true
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "http_allowed_cidrs" {
  description = "CIDRs allowed to reach the EC2 web server on port 80."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# --- EKS ---------------------------------------------------------------------
variable "enable_eks" {
  description = "Create the EKS cluster (and the NAT gateway it needs). Incurs hourly cost."
  type        = bool
  default     = false
}

variable "eks_version" {
  type    = string
  default = "1.36"
}

variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "eks_admin_principal_arns" {
  description = "Extra IAM user/role ARNs granted cluster-admin on EKS."
  type        = list(string)
  default     = []
}
