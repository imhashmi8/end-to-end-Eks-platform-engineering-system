data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "app_codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_codebuild" {
  name               = "${var.name_prefix}-app-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.app_codebuild_assume_role.json
}

data "aws_iam_policy_document" "app_codebuild" {
  statement {
    actions = [
      "eks:DescribeCluster",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [var.ecr_repository_arn]
  }
}

resource "aws_iam_role_policy" "app_codebuild" {
  name   = "${var.name_prefix}-app-codebuild-policy"
  role   = aws_iam_role.app_codebuild.id
  policy = data.aws_iam_policy_document.app_codebuild.json
}

resource "aws_codebuild_project" "app" {
  name         = "${var.name_prefix}-app-build"
  description  = "Builds and publishes application images for ${var.name_prefix}"
  service_role = aws_iam_role.app_codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repository_name
    }

    environment_variable {
      name  = "IMAGE_REPO_URI"
      value = var.ecr_repository_url
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_path
  }
}

data "aws_iam_policy_document" "infra_codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "infra_codebuild" {
  name               = "${var.name_prefix}-infra-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.infra_codebuild_assume_role.json
}

data "aws_iam_policy_document" "infra_codebuild" {
  statement {
    actions = [
      "autoscaling:*",
      "cloudwatch:*",
      "codebuild:*",
      "codeconnections:*",
      "codepipeline:*",
      "ec2:*",
      "ecr:*",
      "eks:*",
      "elasticloadbalancing:*",
      "events:*",
      "iam:*",
      "kms:*",
      "logs:*",
      "s3:*",
      "sts:GetCallerIdentity",
      "cloudformation:*",
      "secretmanager:*"

    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "infra_codebuild" {
  name   = "${var.name_prefix}-infra-codebuild-policy"
  role   = aws_iam_role.infra_codebuild.id
  policy = data.aws_iam_policy_document.infra_codebuild.json
}

resource "aws_codebuild_project" "infra" {
  name         = "${var.name_prefix}-infra-build"
  description  = "Validates and applies Terraform infrastructure for ${var.name_prefix}"
  service_role = aws_iam_role.infra_codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.infra_buildspec_path
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifact_bucket_name
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "app_codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_codepipeline" {
  name               = "${var.name_prefix}-app-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.app_codepipeline_assume_role.json
}

data "aws_iam_policy_document" "app_codepipeline" {
  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.codestar_connection_arn]
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [aws_codebuild_project.app.arn]
  }
}

resource "aws_iam_role_policy" "app_codepipeline" {
  name   = "${var.name_prefix}-app-codepipeline-policy"
  role   = aws_iam_role.app_codepipeline.id
  policy = data.aws_iam_policy_document.app_codepipeline.json
}

resource "aws_codepipeline" "app" {
  name           = "${var.name_prefix}-app-pipeline"
  role_arn       = aws_iam_role.app_codepipeline.arn
  pipeline_type  = "V2"
  execution_mode = "SUPERSEDED"

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "${var.github_owner}/${var.github_repo}"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "AppBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.app.name
      }
    }
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "Source"

      push {
        branches {
          includes = [var.github_branch]
        }

        file_paths {
          includes = [
            "apps/todo-app/**",
            "helm/todo-app/**",
            "gitops/**"
          ]

          excludes = [
            "terraform/**",
            "**/*.md",
            ".gitignore"
          ]
        }
      }
    }
  }
}

data "aws_iam_policy_document" "infra_codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "infra_codepipeline" {
  name               = "${var.name_prefix}-infra-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.infra_codepipeline_assume_role.json
}

data "aws_iam_policy_document" "infra_codepipeline" {
  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.codestar_connection_arn]
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [aws_codebuild_project.infra.arn]
  }
}

resource "aws_iam_role_policy" "infra_codepipeline" {
  name   = "${var.name_prefix}-infra-codepipeline-policy"
  role   = aws_iam_role.infra_codepipeline.id
  policy = data.aws_iam_policy_document.infra_codepipeline.json
}

resource "aws_codepipeline" "infra" {
  name           = "${var.name_prefix}-infra-pipeline"
  role_arn       = aws_iam_role.infra_codepipeline.arn
  pipeline_type  = "V2"
  execution_mode = "SUPERSEDED"

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "${var.github_owner}/${var.github_repo}"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Terraform"

    action {
      name             = "InfraBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.infra.name
      }
    }
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "Source"

      push {
        branches {
          includes = [var.github_branch]
        }

        file_paths {
          includes = [
            "terraform/**"
          ]
        }
      }
    }
  }
}
