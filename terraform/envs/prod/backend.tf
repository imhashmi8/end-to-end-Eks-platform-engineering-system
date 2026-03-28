terraform {
  backend "s3" {
    bucket       = "qamar-terraform-state-ap-south-1"
    key          = "eks/prod/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}
