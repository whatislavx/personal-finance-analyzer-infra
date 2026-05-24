# FinFlow Infrastructure (AWS EKS + ArgoCD GitOps)
Infrastructure repository for **FinFlow** (Personal Finance Analyzer).

This project demonstrates how to design, build, and operate a cloud-native platform using Terraform, AWS EKS (Kubernetes), Helm, ArgoCD, and GitHub Actions, focusing on hands-on experience with production-ready cluster management and GitOps practices.

## Summary
This repo showcases practical DevOps skills:

- Infrastructure as Code on AWS using Terraform modules
- Kubernetes platform setup on EKS with private/public networking
- GitOps deployment model with ArgoCD (app-of-apps)
- Reusable Helm component chart for multiple services
- Secure HTTPS ingress with AWS ALB + ACM
- S3 migration from MinIO with dedicated IAM permissions
- CI-driven configuration injection via GitHub Secrets
- Monitoring stack with Prometheus + Grafana

## Architecture
```text
GitHub Actions (CD) 
        |
        v
GitOps Repo (this repository, manifests updated on deploy)
        |
        v
ArgoCD (root app -> projects -> applications)
        |
        v
EKS Cluster
  - App services: frontend, api, worker
  - Infra services: postgresql, rabbitmq, gotenberg
  - Monitoring: kube-prometheus-stack + Grafana dashboards
        |
        +--> ALB Ingress (HTTPS via ACM certificate)
        +--> AWS S3 bucket (results storage via IAM user credentials)
```

## Tech Stack
- **Cloud:** AWS (EKS, VPC, S3, IAM, ACM, ALB)
- **IaC:** Terraform (`terraform-aws-modules/vpc/aws`, `terraform-aws-modules/eks/aws`)
- **Container Orchestration:** Kubernetes
- **Package Management:** Helm
- **GitOps:** ArgoCD
- **CI/CD:** GitHub Actions (`repository_dispatch`)
- **Observability:** Prometheus, Alertmanager, Grafana

## Repository Structure
```text
.
├── terraform/                 # AWS infrastructure (EKS, VPC, S3, IAM)
├── k8s/
│   ├── argocd/root-app.yaml   # ArgoCD app-of-apps bootstrap
│   ├── templates/
│   │   ├── projects/          # ArgoCD AppProjects
│   │   └── applications/      # ArgoCD Applications (apps, infra, monitoring)
│   ├── charts/
│   │   └── app-component/     # Reusable app chart (Deployment/Service/Ingress/Config/Secret)
│   └── config/                # Monitoring values (kube-prometheus-stack)
└── .github/workflows/cd.yaml  # CD automation + secrets injection
```

## What Is Deployed

### Application Layer (`finflow-apps`)
- `finflow-frontend` (Ingress `/`)
- `finflow-api` (Ingress `/api`, readiness/liveness probes)
- `finflow-worker` (background processing)

### Infrastructure Layer (`finflow-infra`)
- `finflow-database` (Bitnami PostgreSQL)
- `finflow-rabbitmq` (Bitnami RabbitMQ)
- `finflow-gotenberg` (document generation)

### Monitoring Layer (`finflow-monitoring`)
- `kube-prometheus-stack`
- Grafana dashboards as ConfigMaps

## Key Implementation Details

### 1. Reusable Helm app chart
The `k8s/charts/app-component` chart supports:
- optional Service and Ingress
- dynamic ConfigMap/Secret from `valuesObject`
- optional HTTP probes (`liveness` and `readiness`)
- ALB annotations for TLS and redirect

### 2. HTTPS + Domain via GitHub Secrets
Ingress settings are passed through CI and injected into ArgoCD application manifests:
- `APP_DOMAIN`
- `ACM_CERTIFICATE_ARN`

This enables environment-specific domain/certificate management without hardcoding.

### 3. AWS S3 integration
Terraform provisions:
- S3 bucket for result storage
- bucket encryption, versioning, public-access-block
- dedicated IAM user + scoped bucket policy
- access keys exposed as Terraform outputs (sensitive)

### 4. GitOps model
- `root-app.yaml` points ArgoCD to the umbrella `k8s` chart
- ArgoCD creates AppProjects and Applications automatically
- sync is automated (`prune` + `selfHeal`)

## Deployment Flow
1. App release event triggers GitHub Actions (`repository_dispatch`).
2. Workflow updates image tags and injects secrets/placeholders in GitOps manifests.
3. Changes are committed back to this repository.
4. ArgoCD detects Git changes and syncs cluster state.

## Quick Start

### Prerequisites
- AWS CLI configured
- Terraform `>= 1.5.0`
- `kubectl`, `helm`
- Existing GitHub repository secrets (see below)

### 1) Provision infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2) Configure kubectl
Use output value or run:
```bash
aws eks update-kubeconfig --region eu-central-1 --name finflow-prod-eks
```

### 3) Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f k8s/argocd/root-app.yaml
```

### 4) Access ArgoCD UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open `https://localhost:8080`.

## Required GitHub Secrets

### Registry / GitOps
- `DOCKERHUB_USERNAME`
- `GITOPS_REPO_URL`

### App secrets
- `DB_PASSWORD`
- `JWT_SECRET_KEY`
- `RABBITMQ_PASSWORD`

### S3 / AWS app config
- `S3_ACCESS_KEY`
- `S3_SECRET_KEY`
- `S3_BUCKET_NAME`
- `AWS_REGION`

### HTTPS ingress
- `APP_DOMAIN`
- `ACM_CERTIFICATE_ARN`
