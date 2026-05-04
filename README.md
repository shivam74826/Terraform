# 🏗️ Terraform — AWS Infrastructure as Code

[![Terraform](https://img.shields.io/badge/Terraform-1.6%2B-7B42BC?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Supported-FF9900?style=flat-square&logo=amazonaws)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

Production-grade AWS infrastructure using Terraform modules. Covers VPC networking, EC2 provisioning, S3 state backend, and multi-environment (dev/prod) deployments with remote state locking.

---

## 📁 Repository Structure

```
terraform/
├── modules/
│   ├── vpc/                    # VPC, subnets, IGW, route tables
│   ├── ec2/                    # EC2 instances, key pairs, security groups
│   └── s3-backend/             # Remote state S3 bucket + DynamoDB lock table
├── environments/
│   ├── dev/                    # Development environment
│   └── prod/                   # Production environment
├── .github/workflows/
│   └── terraform.yml           # GitHub Actions: plan on PR, apply on merge
└── README.md
```

---

## 🚀 Quick Start

```bash
# 1. Configure AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"

# 2. Set up remote state (first time only)
cd modules/s3-backend
terraform init && terraform apply

# 3. Deploy dev environment
cd environments/dev
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## 🏗️ Modules

### VPC Module
- Custom VPC with public/private subnets across 2 AZs
- Internet Gateway + NAT Gateway
- Route tables with proper associations
- Security group rules (SSH, HTTP, HTTPS)

### EC2 Module
- Dynamic instance provisioning via `for_each`
- Environment-based instance sizing (`t2.micro` for dev, `t2.large` for prod)
- AMI lookup by region using a variable map
- Attaches key pair and security group automatically

### S3 Backend Module
- S3 bucket for Terraform state with versioning enabled
- DynamoDB table for state locking (prevents concurrent applies)
- Server-side encryption (AES-256)

---

## 🔧 Key Terraform Features Used

| Feature | Where Used |
|---|---|
| `for_each` | Provision multiple EC2 instances from a list |
| `dynamic blocks` | Flexible security group ingress rules |
| `try()` | Safe port range defaults |
| `contains()` validation | Restrict allowed regions and environments |
| `fileexists()` validation | Ensure SSH key exists before apply |
| Remote state (S3 + DynamoDB) | State locking and versioning |
| GitHub Actions CI/CD | Automated plan on PR, apply on merge to main |

---

## 📸 Architecture

```
Internet
    │
    ▼
[Internet Gateway]
    │
    ▼
[Public Subnet]──[EC2 Web Server]──[Security Group: 22, 80, 443]
    │
    ▼
[Private Subnet]──[EC2 App Server]──[Security Group: 8080 internal]
    │
    ▼
[NAT Gateway] (outbound for private subnet)
```

---

## ⚙️ Variables Reference

| Variable | Type | Description |
|---|---|---|
| `region` | string | AWS region (`ap-south-1` or `us-west-1`) |
| `environment` | string | Deployment environment (`test` or `prod`) |
| `servers_name` | list(string) | Names for EC2 instances |
| `ami_id` | map | AMI IDs per region |
| `key_pair` | string | Path to public SSH key |
| `ports` | list(object) | Ingress port rules for security group |

---

## 🔒 Security Best Practices

- ✅ SSH key pair managed via Terraform variable (never hardcoded)
- ✅ Remote state encrypted at rest in S3
- ✅ DynamoDB state locking prevents concurrent modifications
- ✅ Least-privilege security groups (only required ports open)
- ✅ Private subnets for application servers (no direct internet access)
- ✅ Sensitive variables read from `terraform.tfvars` (git-ignored)

---

## 📋 Related Repos

- [k8s-hetzner-cluster-setup](https://github.com/shivam74826/k8s-hetzner-cluster-setup) — Hetzner Cloud infra with Terraform
- [jenkins-k8s-cicd-pipeline](https://github.com/shivam74826/jenkins-k8s-cicd-pipeline) — CI/CD pipelines

---

*Part of my [DevOps Portfolio](https://github.com/shivam74826)*
