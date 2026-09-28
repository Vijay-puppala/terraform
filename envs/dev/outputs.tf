output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "ec2_public_ip" {
  value = module.network.ec2_public_ip
}

output "s3_bucket_name" {
  value = module.s3.bucket_id
}

output "iam_user_arns" {
  value = module.iam.user_arns
}

output "eks_cluster_name" {
  value = one(module.eks[*].cluster_name)
}

output "eks_cluster_endpoint" {
  value = one(module.eks[*].cluster_endpoint)
}

output "eks_kubeconfig_command" {
  description = "Run this to configure kubectl."
  value       = var.enable_eks ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks[0].cluster_name}" : null
}
