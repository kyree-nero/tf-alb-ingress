
module "base" {
  source="./base"
  tags = var.tags
  cluster-name = var.cluster-name
  env_name = var.env_name
  aws_region = var.aws_region
}



module "addons" {
  source = "./addons"
  cluster-name = var.cluster-name
  vpc_id = module.base.vpc_id
  aws_region = var.aws_region
  oidc_provider_arn =  module.base.oidc_provider_arn
  env_name = var.env_name

  depends_on = [
      module.base
  ]
}

//until we find a way to wait for the elb that the ingress creates... manually wait until this is ready... then open it up

# module "apps"{
#   source = "./apps"

#   lb_dns_name = module.addons.lb_dns_name
#   depends_on = [
#     module.addons
#   ]
# }
