# resource "helm_release" "app" {
#   name       = "123"
#   chart      = "./helm-charts/123"
  
#   set {
#     name  = "lb_dns_name"
#     value = var.lb_dns_name
#   }
  
# }


resource "helm_release" "app" {
  name       = "app"
  //chart      = "./helm-charts/fruit"
  chart      = "./helm-charts/123"
  
  set {
    name  = "lb_dns_name"
    value = var.lb_dns_name
  }
  
}