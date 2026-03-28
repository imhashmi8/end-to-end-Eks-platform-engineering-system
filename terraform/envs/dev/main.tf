module "vpc" {
  source = "../../modules/vpc"

  name = "dev-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24"]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name                         = "dev-eks"
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  vpc_id                               = module.vpc.vpc_id
  private_subnets                      = module.vpc.private_subnets

  instance_types = ["t3.medium"]
  min_size       = 1
  max_size       = 2
  desired_size   = 1
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.ecr_repository_name
  force_delete    = true
}

module "cicd" {
  source = "../../modules/cicd"

  name_prefix             = "${var.project_name}-dev"
  artifact_bucket_name    = var.cicd_artifact_bucket_name
  github_owner            = var.github_owner
  github_repo             = var.github_repo
  github_branch           = var.github_branch
  codestar_connection_arn = var.codestar_connection_arn
  buildspec_path          = var.buildspec_path
  ecr_repository_name     = module.ecr.repository_name
  ecr_repository_arn      = module.ecr.repository_arn
  ecr_repository_url      = module.ecr.repository_url
}
