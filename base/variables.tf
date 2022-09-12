
variable "tags" {
  description = "tags"
  default = {"sometag" = "s"}
}

variable "cluster-name" {
  description = "cluster-name"
  type = string
}

variable "env_name" {
  description = "env_name"
  type = string
}

variable "aws_region" {
  description = "aws_region"
  type = string
}


