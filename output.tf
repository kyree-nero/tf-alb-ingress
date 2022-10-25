


/*
output "kubeconfig_command" {
    value = "export KUBECONFIG=${path.cwd}/../k8s-${aws_eks_cluster.this.name}.yaml"
}*/


output "lb_dns_name" {
    value = module.addons.lb_dns_name
}
