  
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "alb-ingress-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${var.aws_region}a", "${var.aws_region}b"]
  //public_subnets     = ["10.0.101.0/27", "10.0.102.0/27"]
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
  //private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"] 
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
  enable_nat_gateway = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24"]
  intra_subnets   = ["10.0.7.0/28", "10.0.7.16/28"]
}
  

  resource "aws_security_group" "eks" {
    name        = "${var.env_name} eks cluster"
    description = "Allow traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
      description      = "World"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    # tags = merge({
    #   Name = "EKS ${var.env_name}",
    #   "kubernetes.io/cluster/${var.cluster-name}": "owned"
    # }, var.tags)
  }

  module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "18.19.0"

    cluster_name                    = var.cluster-name
    cluster_version                 = "1.21"
    cluster_endpoint_private_access = true
    cluster_endpoint_public_access  = true
    cluster_additional_security_group_ids = [aws_security_group.eks.id]

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      disk_size              = 50
      instance_types         = ["t3.medium", "t3.large"]
      vpc_security_group_ids = [aws_security_group.eks.id]
    }

    eks_managed_node_groups = {
      
      green = {
        min_size     = 1
        max_size     = 10
        desired_size = 3

        instance_types = ["t3.medium"]
        capacity_type  = "SPOT"
        labels = var.tags 
        taints = {}

        tags = var.tags

      }
    }
/*
    provisioner "local-exec" {
        command = "aws eks update-kubeconfig --kubeconfig ${path.cwd}/.terraform/k8s-${self.name}.yaml --name ${self.name}"
    }
*/
    tags = var.tags
  }


module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.env_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}




resource "kubernetes_service_account" "service-account" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}






resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
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

/*
resource "helm_release" "app" {
  name       = "2048"
  chart      = "./helm-charts/2048"
  depends_on = [
    helm_release.lb
  ]

}
*/

 //aws eks update-kubeconfig --kubeconfig kubeconfig/kube.config.yaml --name diu-eks-cluster
//export KUBECONFIG=./kubeconfig/kube.config.yaml 
//kubectl get ingress/2048-ingress -n 2048-game
//curl $(kubectl get ingress/2048-ingress -n 2048-game  | grep -v AGE | awk '{split($0,a," "); print a[4]}')