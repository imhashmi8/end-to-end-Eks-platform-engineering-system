output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "app_codepipeline_name" {
  value = module.cicd.app_codepipeline_name
}

output "infra_codepipeline_name" {
  value = module.cicd.infra_codepipeline_name
}

output "app_codebuild_project_name" {
  value = module.cicd.app_codebuild_project_name
}

output "infra_codebuild_project_name" {
  value = module.cicd.infra_codebuild_project_name
}
