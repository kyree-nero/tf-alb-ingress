resource "helm_release" "app" {
  name       = "2048"
  chart      = "./helm-charts/2048"
  

}