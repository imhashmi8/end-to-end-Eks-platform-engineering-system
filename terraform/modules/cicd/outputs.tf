output "artifact_bucket_name" {
  value = aws_s3_bucket.artifacts.bucket
}

output "app_codebuild_project_name" {
  value = aws_codebuild_project.app.name
}

output "infra_codebuild_project_name" {
  value = aws_codebuild_project.infra.name
}

output "app_codepipeline_name" {
  value = aws_codepipeline.app.name
}

output "infra_codepipeline_name" {
  value = aws_codepipeline.infra.name
}

output "app_codebuild_role_arn" {
  value = aws_iam_role.app_codebuild.arn
}

output "infra_codebuild_role_arn" {
  value = aws_iam_role.infra_codebuild.arn
}

output "app_codepipeline_role_arn" {
  value = aws_iam_role.app_codepipeline.arn
}

output "infra_codepipeline_role_arn" {
  value = aws_iam_role.infra_codepipeline.arn
}
