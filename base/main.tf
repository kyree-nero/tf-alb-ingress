
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "alb-ingress-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${var.aws_region}a", "${var.aws_region}b"]
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
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
