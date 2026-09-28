###############################################################################
# IAM module
#   - Groups, users and group membership
#   - Service roles used by the other modules (EC2 instance profile, EKS)
###############################################################################

data "aws_partition" "current" {}

locals {
  policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
}

# -----------------------------------------------------------------------------
# Groups
# -----------------------------------------------------------------------------
resource "aws_iam_group" "this" {
  for_each = var.groups

  name = "${var.name_prefix}-${each.key}"
  path = "/${var.name_prefix}/"
}

resource "aws_iam_group_policy_attachment" "this" {
  for_each = {
    for pair in flatten([
      for group, cfg in var.groups : [
        for policy in cfg.managed_policy_names : {
          key    = "${group}:${policy}"
          group  = group
          policy = policy
        }
      ]
    ]) : pair.key => pair
  }

  group      = aws_iam_group.this[each.value.group].name
  policy_arn = "${local.policy_prefix}/${each.value.policy}"
}

# Every user can manage their own password and MFA device.
data "aws_iam_policy_document" "self_manage" {
  statement {
    sid = "AllowSelfManageCredentials"
    actions = [
      "iam:ChangePassword",
      "iam:GetUser",
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::*:user/*/$${aws:username}",
      "arn:${data.aws_partition.current.partition}:iam::*:mfa/$${aws:username}",
    ]
  }
}

resource "aws_iam_policy" "self_manage" {
  name   = "${var.name_prefix}-self-manage-credentials"
  policy = data.aws_iam_policy_document.self_manage.json
}

resource "aws_iam_group_policy_attachment" "self_manage" {
  for_each = aws_iam_group.this

  group      = each.value.name
  policy_arn = aws_iam_policy.self_manage.arn
}

# -----------------------------------------------------------------------------
# Users
# Access keys / login profiles are intentionally NOT created here: they would
# be stored in plaintext in the Terraform state. Issue them out of band.
# -----------------------------------------------------------------------------
resource "aws_iam_user" "this" {
  for_each = var.users

  name          = each.key
  path          = "/${var.name_prefix}/"
  force_destroy = true
}

resource "aws_iam_user_group_membership" "this" {
  for_each = var.users

  user   = aws_iam_user.this[each.key].name
  groups = [for g in each.value.groups : aws_iam_group.this[g].name]
}

# -----------------------------------------------------------------------------
# EC2 instance role (SSM Session Manager access, no SSH keys needed)
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "${local.policy_prefix}/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# -----------------------------------------------------------------------------
# EKS cluster role
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.name_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "${local.policy_prefix}/AmazonEKSClusterPolicy"
}

# -----------------------------------------------------------------------------
# EKS worker node role
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eks_node" {
  name               = "${var.name_prefix}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonSSMManagedInstanceCore",
  ])

  role       = aws_iam_role.eks_node.name
  policy_arn = "${local.policy_prefix}/${each.value}"
}
