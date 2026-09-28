variable "name_prefix" {
  description = "Prefix applied to resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be /16 so cidrsubnet() yields /24 subnets."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across (EKS needs at least 2)."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "az_count must be between 2 and 4."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway so private subnets (e.g. EKS nodes) can reach the internet."
  type        = bool
  default     = true
}

variable "eks_cluster_name" {
  description = "If set, subnets are tagged for discovery by this EKS cluster."
  type        = string
  default     = null
}

variable "create_ec2" {
  description = "Whether to create the example EC2 web server."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "instance_profile_name" {
  description = "IAM instance profile to attach to the EC2 instance (from the iam module)."
  type        = string
  default     = null
}

variable "http_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the web server on port 80."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
