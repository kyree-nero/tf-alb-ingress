
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
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
   
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internal"
  }

   set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
    value = "'true'"
  }
}

data "aws_lb" "this" {
  tags = {
    "kubernetes.io/service-name"="kube-system/nginx-ingress-controller-nginx-ingress"
  }
  depends_on = [
    helm_release.ingress-contr
  ]
}


resource "null_resource" "patience" {
   depends_on = [ data.aws_lb.this, helm_release.ingress-contr ]
    
    triggers = {
      lb_dns_name = "${data.aws_lb.this.dns_name}"
    }

    provisioner "local-exec" {
      command = "sleep 300"
    }
}



#  resource "helm_release" "ingress-contr" {
#   name       = "nginx-ingress-controller"
#   repository = "https://helm.nginx.com/stable"
#   chart      = "nginx-ingress"
#   version = "0.15.0"
#   namespace  = "kube-system"

#   set { 
#     name ="debug"
#     value =true
#   }
#   //controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
#     value = "nlb"
#   }
  
# }


# data "aws_lb" "this" {
#   tags = {
#     "kubernetes.io/service-name"="kube-system/nginx-ingress-controller-nginx-ingress"
#   }
# }


# resource "null_resource" "patience" {
#    depends_on = [ data.aws_lb.this, helm_release.ingress-contr ]
    
#     triggers = {
#       lb_dns_name = "${data.aws_lb.this.dns_name}"
#     }

#     provisioner "local-exec" {
#       command = "sleep 300"
#     }
# }



# data "dns_a_record_set" "lb_dns_a" {
#   depends_on = [ "null_resource.patience" ]
#   host  = "${data.aws_lb.this.dns_name}"
# }


