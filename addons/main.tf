


# resource "helm_release" "ingress-contr" {
#   name       = "nginx-ingress-controller"
#   repository = "https://helm.nginx.com/stable"
#   chart      = "nginx-ingress"
#   version = "0.15.0"
#   namespace  = "kube-system"

# }

 resource "helm_release" "ingress-contr" {
  name       = "nginx-ingress-controller"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version = "0.15.0"
  namespace  = "kube-system"

  set { 
    name ="debug"
    value =true
  }
  //controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  
}

# //hackey wait for ingress to show a dns record
# data "aws_resourcegroupstaggingapi_resources" "load_balancer" {
#   resource_type_filters = [
#     //"elasticloadbalancing:loadbalancer"
#     "elasticloadbalancingv2::loadbalancer"
#   ]

#   tag_filter {
#     key    = "kubernetes.io/service-name"
#     values = ["kube-system/nginx-ingress-controller-nginx-ingress"]
#   }

#   depends_on = [
#     helm_release.ingress-contr
#   ]
  
# }


# data "aws_elb" "this" {
#   name = split("/", 
#     data.aws_resourcegroupstaggingapi_resources.load_balancer.resource_tag_mapping_list[0].resource_arn
#   )[1]
# }

data "aws_lb" "this" {
  tags = {
    "kubernetes.io/service-name"="kube-system/nginx-ingress-controller-nginx-ingress"
  }
}


# resource "null_resource" "patience" {
#    depends_on = [ data.aws_elb.this, helm_release.ingress-contr ]
    
#     triggers = {
#       lb_dns_name = "${data.aws_elb.this.dns_name}"
#     }

#     provisioner "local-exec" {
#       command = "sleep 300"
#     }
# }

resource "null_resource" "patience" {
   depends_on = [ data.aws_lb.this, helm_release.ingress-contr ]
    
    triggers = {
      lb_dns_name = "${data.aws_lb.this.dns_name}"
    }

    provisioner "local-exec" {
      command = "sleep 300"
    }
}


# data "dns_a_record_set" "lb_dns_a" {
#   depends_on = [ "null_resource.patience" ]
#   host  = "${data.aws_elb.this.dns_name}"
# }

data "dns_a_record_set" "lb_dns_a" {
  depends_on = [ "null_resource.patience" ]
  host  = "${data.aws_lb.this.dns_name}"
}


