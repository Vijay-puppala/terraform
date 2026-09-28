###############################################################################
# dev environment: wires the logical modules together
#   iam      -> users, groups, service roles
#   network  -> VPC, subnets, NAT, EC2
#   s3       -> application bucket
#   eks      -> Kubernetes cluster (optional, costs ~$0.10/h + nodes)
###############################################################################

locals {
  name_prefix  = "${var.project}-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"
}

module "iam" {
  source = "../../modules/iam"

  name_prefix = local.name_prefix
  users       = var.iam_users
}

module "network" {
  source = "../../modules/network"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  enable_nat_gateway = var.enable_eks # private EKS nodes need outbound internet
  eks_cluster_name   = var.enable_eks ? local.cluster_name : null

  create_ec2            = var.create_ec2
  instance_type         = var.ec2_instance_type
  instance_profile_name = module.iam.ec2_instance_profile_name
  http_allowed_cidrs    = var.http_allowed_cidrs
}

module "s3" {
  source = "../../modules/s3"

  name_prefix   = local.name_prefix
  bucket_suffix = "data"
  force_destroy = true # convenient for a sandbox; set false for real data
}

module "eks" {
  source = "../../modules/eks"
  count  = var.enable_eks ? 1 : 0

  cluster_name         = local.cluster_name
  kubernetes_version   = var.eks_version
  cluster_role_arn     = module.iam.eks_cluster_role_arn
  node_role_arn        = module.iam.eks_node_role_arn
  subnet_ids           = module.network.private_subnet_ids
  admin_principal_arns = var.eks_admin_principal_arns
  node_instance_types  = var.eks_node_instance_types
}
