output "oidc_provider_arn" {
    value = module.eks.oidc_provider_arn
}

output "vpc_id" {
    value = module.vpc.vpc_id
}

output "cluster_id" {
    value =  module.eks.cluster_id
}

output "public_subnets" {
    value = module.vpc.public_subnets
}

output "private_subnets" {
    value = module.vpc.private_subnets
}