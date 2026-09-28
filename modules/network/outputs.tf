output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "web_security_group_id" {
  description = "Security group ID of the web server."
  value       = aws_security_group.web.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 web server."
  value       = one(aws_instance.web[*].id)
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 web server."
  value       = one(aws_instance.web[*].public_ip)
}
