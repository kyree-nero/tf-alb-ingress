
variable "cluster-name" {
  description = "cluster-name"
  type = string
}

variable "vpc_id" {
  description = "vpc_id"
  type = string
}

variable "aws_region" {
  description = "aws_region"
  type = string
}

variable "oidc_provider_arn" {
  description = "oidc_provider_arn"
  type = string
}

variable "env_name" {
  description = "env_name"
  type = string
}
