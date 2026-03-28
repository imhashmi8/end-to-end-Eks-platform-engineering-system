variable "repository_name" {
  type = string
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "force_delete" {
  type    = bool
  default = false
}

variable "max_image_count" {
  type    = number
  default = 20
}
