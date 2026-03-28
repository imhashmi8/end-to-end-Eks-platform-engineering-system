variable "cluster_name" {}
variable "vpc_id" {}
variable "private_subnets" { type = list(string) }

variable "instance_types" { type = list(string) }
variable "min_size" {}
variable "max_size" {}
variable "desired_size" {}