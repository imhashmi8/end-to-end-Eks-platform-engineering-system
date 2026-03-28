output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "codepipeline_name" {
  value = module.cicd.codepipeline_name
}

output "codebuild_project_name" {
  value = module.cicd.codebuild_project_name
}
