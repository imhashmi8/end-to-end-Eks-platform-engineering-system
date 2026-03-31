variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_profile" {
  type    = string
  default = "todo-app-prod"
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "project_name" {
  type    = string
  default = "todo-app-platform"
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

variable "infra_buildspec_path" {
  type    = string
  default = "terraform/buildspec-prod.yml"
}

variable "ecr_repository_name" {
  type = string
}

variable "cicd_artifact_bucket_name" {
  type = string
}
