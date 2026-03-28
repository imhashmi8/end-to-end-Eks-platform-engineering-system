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

  cluster_name    = "dev-eks"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  instance_types = ["t3.medium"]
  min_size       = 1
  max_size       = 2
  desired_size   = 1
}
