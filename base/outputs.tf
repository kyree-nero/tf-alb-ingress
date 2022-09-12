output "oidc_provider_arn" {
    value = module.eks.oidc_provider_arn
}

output "vpc_id" {
    value = module.vpc.vpc_id
}

output "cluster_id" {
    value =  module.eks.cluster_id
}
