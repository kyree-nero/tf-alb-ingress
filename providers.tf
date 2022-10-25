
data "aws_eks_cluster" "eks-cluster" {
  name =  module.base.cluster_id//module.eks.cluster_id
}


data "aws_eks_cluster_auth" "eks-cluster" {
  name = module.base.cluster_id//module.eks.cluster_id
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks-cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks-cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks-cluster.token
  }
}

# provider "kubectl" {
#   host                   = data.aws_eks_cluster.eks-cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks-cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks-cluster.token
#   load_config_file       = false
# }