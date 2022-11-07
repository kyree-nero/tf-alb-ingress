


/*
output "kubeconfig_command" {
    value = "export KUBECONFIG=${path.cwd}/../k8s-${aws_eks_cluster.this.name}.yaml"
}*/


output "lb_dns_name" {
    value = module.addons.lb_dns_name
}

 output "ec2_dns" {
     value = [module.public_ec2_instance.public_dns]
}

#  output "ec2_pem" {
#      value = tls_private_key.rsa-4096-private-key.private_key_pem
#      sensitive = true
#  }
