variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_profile" {
  type    = string
  default = "portfolio-dev"
}

variable "project_name" {
  type    = string
  default = "portfolio-platform"
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "codestar_connection_arn" {
  type = string
}

variable "buildspec_path" {
  type    = string
  default = "buildspec.yml"
}

variable "ecr_repository_name" {
  type = string
}

variable "cicd_artifact_bucket_name" {
  type = string
}
