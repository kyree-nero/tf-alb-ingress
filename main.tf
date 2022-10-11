
module "base" {
  source="./base"
  tags = var.tags
  cluster-name = var.cluster-name
  env_name = var.env_name
  aws_region = var.aws_region
}


/*
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
    */

/*
resource "aws_iam_policy" "alb_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "My test policy"
  policy = file("./addons/iam_policy.json")
}

data "aws_caller_identity" "current" {}



data "aws_iam_policy_document" "alb_trust_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      //identifiers  =  ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/413C03D0EBEB1A675AC430EEC24FF4B1"]
      identifiers  =  [replace("arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.base.oidc_issuer_url}","https://", "" )]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "ForAnyValue:StringEquals"
      //variable = "oidc.eks.eu-west-1.amazonaws.com/id/413C03D0EBEB1A675AC430EEC24FF4B1:aud"
      variable = replace("${module.base.oidc_issuer_url}:aud","https://", "" ) 
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      //variable = "oidc.eks.eu-west-1.amazonaws.com/id/413C03D0EBEB1A675AC430EEC24FF4B1:sub"
      variable = replace("${module.base.oidc_issuer_url}:sub","https://", "" ) 
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    
  }
}



resource "aws_iam_role" "alb_role" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.alb_trust_policy_doc.json
}



resource "aws_iam_role_policy_attachment" "alb_policy_attach" {
    role       = aws_iam_role.alb_role.name
    policy_arn = aws_iam_policy.alb_policy.arn
}


resource "helm_release" "sa" {
  name       = "sa"
  chart      = "./helm-charts/alb-sa"
  
  

  set {
    name  = "account_id"
    value = "${data.aws_caller_identity.current.account_id}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.alb_policy_attach
  ]
}



resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    helm_release.sa
  ]

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.base.vpc_id//module.vpc.vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.eu-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.cluster-name
  }

  
}

*/


# module "addons" {
#   source = "./addons"
#   cluster-name = var.cluster-name
#   vpc_id = module.base.vpc_id
#   aws_region = var.aws_region
#   oidc_provider_arn =  module.base.oidc_provider_arn
#   env_name = var.env_name
# }

/*

module "apps"{
  source = "./apps"
  depends_on = [
    helm_release.lb
  ]

}
*/





module "addons" {
  source = "./addons"
  cluster-name = var.cluster-name
  vpc_id = module.base.vpc_id
  aws_region = var.aws_region
  oidc_provider_arn =  module.base.oidc_provider_arn
  env_name = var.env_name
  oidc_issuer_url = module.base.oidc_issuer_url

  depends_on = [
    module.base
  ]
}



module "apps"{
  source = "./apps"
  depends_on = [
    module.addons
  ]

}
