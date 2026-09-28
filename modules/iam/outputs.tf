output "user_arns" {
  description = "ARNs of the created IAM users."
  value       = { for k, u in aws_iam_user.this : k => u.arn }
}

output "group_names" {
  description = "Names of the created IAM groups."
  value       = { for k, g in aws_iam_group.this : k => g.name }
}

output "ec2_instance_profile_name" {
  description = "Instance profile to attach to EC2 instances."
  value       = aws_iam_instance_profile.ec2.name
  depends_on  = [aws_iam_role_policy_attachment.ec2_ssm]
}

# depends_on ensures consumers wait for the policies to be attached,
# otherwise EKS cluster/node group creation can fail.
output "eks_cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane."
  value       = aws_iam_role.eks_cluster.arn
  depends_on  = [aws_iam_role_policy_attachment.eks_cluster]
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS managed node groups."
  value       = aws_iam_role.eks_node.arn
  depends_on  = [aws_iam_role_policy_attachment.eks_node]
}
