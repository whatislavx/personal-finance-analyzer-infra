output "vpc_id" {
  description = "VPC id created by the module"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet ids"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet ids"
  value       = module.vpc.public_subnets
}
