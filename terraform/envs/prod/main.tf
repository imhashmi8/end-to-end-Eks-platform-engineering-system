module "vpc" {
  source = "../../modules/vpc"

  name = "prod-vpc"
  cidr = "10.20.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
  public_subnets  = ["10.20.101.0/24", "10.20.102.0/24"]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = "prod-eks"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  instance_types = ["t3.large"]
  min_size       = 2
  max_size       = 5
  desired_size   = 3
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.ecr_repository_name
}

module "cicd" {
  source = "../../modules/cicd"

  name_prefix             = "${var.project_name}-prod"
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
