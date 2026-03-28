variable "name" {}
variable "cidr" {}
variable "azs" { typtype = list(string) }
variable "public_subnet_cidrs" { typtype = list(string) }
variable "private_subnet_cidrs" { typtype = list(string) }