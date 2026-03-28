# End-to-End EKS Platform Engineering System

This project is my hands-on platform engineering portfolio project built on AWS. I designed it to show how I can provision cloud infrastructure, build and publish application images, package workloads for Kubernetes, and manage deployments using GitOps on Amazon EKS.

The goal of the project is to combine:

- Terraform for infrastructure as code
- Amazon EKS for Kubernetes
- AWS CodePipeline and CodeBuild for CI
- Amazon ECR for container images
- Helm for Kubernetes packaging
- ArgoCD for GitOps continuous delivery
- MongoDB Atlas as the external application database

## Architecture

At a high level, the platform follows this flow:

```text
GitHub
  |
  |-- App / Helm / GitOps changes --> App Pipeline --> CodeBuild --> ECR --> ArgoCD --> EKS
  |
  |-- Terraform changes -----------> Infra Pipeline --> CodeBuild --> Terraform Apply --> AWS
```

The deployed application flow looks like this:

```text
User --> EKS Service / Ingress --> Todo App --> MongoDB Atlas
```

## What I Built

### Infrastructure Layer

I used Terraform to provision and organize the AWS platform in a modular way.

Current Terraform modules include:

- `vpc`
- `eks`
- `ecr`
- `cicd`

Environment-specific stacks are separated into:

- `terraform/envs/dev`
- `terraform/envs/prod`

This lets me manage different cluster sizes, CI/CD settings, and image repositories for dev and prod independently.

### CI/CD Layer

I intentionally split CI into two separate pipelines:

- App pipeline
  - triggers on `apps/todo-app/**`, `helm/todo-app/**`, and `gitops/**`
  - builds the application image
  - pushes the image to Amazon ECR

- Infra pipeline
  - triggers on `terraform/**`
  - runs Terraform init, validate, plan, and apply
  - manages infrastructure changes separately from application delivery

This separation keeps infrastructure changes isolated from application deployments and reflects a cleaner platform operating model.

### Application Layer

For the workload, I imported and adapted a Node.js Todo application and used MongoDB Atlas as the backend database.

The application lives in:

- `apps/todo-app`

It includes:

- `server.js`
- `Dockerfile`
- environment-specific CodeBuild specs

I used MongoDB Atlas so the application remains stateless inside Kubernetes and does not need an in-cluster MongoDB deployment.

### Kubernetes Packaging

I packaged the workload with Helm.

The chart lives in:

- `helm/todo-app`

It manages:

- Deployment
- Service
- Ingress
- HPA
- ServiceAccount
- environment variables
- secret-based MongoDB connection injection

### GitOps Layer

I scaffolded a GitOps structure for ArgoCD:

- `gitops/dev`
- `gitops/prod`

Each environment contains:

- ArgoCD `Application` manifest
- environment-specific Helm values

ArgoCD is intended to watch this Git state and reconcile it into the cluster.

## Repository Structure

```text
.
├── apps/
│   └── todo-app/
├── gitops/
│   ├── dev/
│   └── prod/
├── helm/
│   └── todo-app/
└── terraform/
    ├── buildspec-dev.yml
    ├── buildspec-prod.yml
    ├── envs/
    │   ├── dev/
    │   └── prod/
    ├── global/
    └── modules/
        ├── cicd/
        ├── ecr/
        ├── eks/
        └── vpc/
```

## How the Delivery Flow Works

### App Delivery

1. A change is pushed to the app, Helm chart, or GitOps files.
2. The app pipeline is triggered by CodePipeline.
3. CodeBuild builds the Docker image.
4. The image is pushed to Amazon ECR.
5. ArgoCD uses the GitOps layer to deploy the workload into EKS.

### Infrastructure Delivery

1. A change is pushed under `terraform/`.
2. The infra pipeline is triggered by CodePipeline.
3. CodeBuild runs Terraform commands.
4. Infrastructure is reconciled into AWS.

## Key Design Decisions

- I used separate app and infra pipelines to avoid mixing infrastructure changes with application delivery.
- I used MongoDB Atlas instead of running MongoDB inside the cluster to keep the workload simpler and more production-aligned.
- I used Helm to package runtime configuration for Kubernetes instead of mixing Kubernetes manifests into Terraform.
- I chose ArgoCD for deployment so the platform follows a GitOps workflow instead of direct imperative deployments.
- I parameterized dev and prod independently to reflect real environment separation.

## Tools and Services Used

- Terraform
- AWS VPC
- Amazon EKS
- Amazon ECR
- AWS CodePipeline
- AWS CodeBuild
- Helm
- ArgoCD
- MongoDB Atlas
- Docker
- GitHub

## Current Status

Implemented so far:

- Terraform module structure for AWS platform resources
- dev and prod environments
- EKS clusters
- ECR repositories
- separate app and infra pipelines
- Node.js Todo app containerization
- Helm chart for Kubernetes deployment
- GitOps folder structure and ArgoCD application manifests

Next improvements I can continue with:

- automatic GitOps image tag update from the app pipeline
- ArgoCD bootstrap and access automation
- Prometheus and Grafana setup
- k6 load testing
- SLOs and alerting
- tighter IAM permissions for infra pipeline roles

## Commands I Used Frequently

Terraform:

```bash
cd terraform/envs/dev
terraform init -reconfigure
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Helm:

```bash
helm lint helm/todo-app
helm template todo-app helm/todo-app -f helm/todo-app/values-prod.yaml
helm upgrade --install todo-app helm/todo-app -n prod -f helm/todo-app/values-prod.yaml
```

Kubernetes:

```bash
kubectl get nodes
kubectl get pods -n prod
kubectl logs -n prod deploy/todo-app
```

## Portfolio Summary

This project demonstrates how I think about platform engineering as a full system rather than a single tool. I combined infrastructure provisioning, Kubernetes operations, CI/CD design, application packaging, and GitOps delivery into one working AWS-based platform that I can continue extending with observability, reliability, and performance tooling.
