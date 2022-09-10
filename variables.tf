variable "aws_region" {
    type        = string
}

variable "env_name" {
    type        = string
}

variable "tags" {
    type        = map
    default = {"sometag" = "s"}
}

# variable "custom_tags" {
#   description = "AWS Custom tags"
#   type        = map
# }

# variable "desired_number_nodes" {
#   description = "Desired number of Kubernetes nodes in AWS Node Group"
#   type        = number
# }

variable "cluster-name" {
  description = "AWS EKS cluster name"
  type        = string
}


# variable "vpn_cidr_block" {
#   description = "home cidr"
#   type        = string
# }


# variable "kubernetes-version" {
#   description = "AWS EKS cluster Kubernetes version"
#   type        = string
# }

# variable "logging_enabled" {
#   description = "logging enabled -- can be true or false"
#   type        = string
# }

# variable "logging_type" {
#   description = "logging type -- can be fluent-bit or fluentd"
#   type        = string
# }

# variable "max_number_nodes" {
#   description = "Max number of Kubernetes nodes in AWS Node Group"
#   type        = number
# }
# variable "min_number_nodes" {
#   description = "Min number of Kubernetes nodes in AWS Node Group"
#   type        = number
# }


# variable "nodes_instance_type" {
#   description = "Nodes instance type"
#   type        = string
# }

# variable "ssh_public_key" {
#   description = "SSH public key"
#   type        = string
# }

# variable "tcp_ports" {
#   description = "TCP port to be allowed by AWS Security Group"
#   type        = list
# }

