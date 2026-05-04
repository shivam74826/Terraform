terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "shivam-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "devops-portfolio"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "shivam74826"
    }
  }
}

# -------------------------------------------------------------------
# VPC Module
# -------------------------------------------------------------------
module "vpc" {
  source      = "../../modules/vpc"
  environment = var.environment
  cidr_block  = "10.0.0.0/16"

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

  availability_zones = ["${var.region}a", "${var.region}b"]
}

# -------------------------------------------------------------------
# EC2 Module — Web Servers
# -------------------------------------------------------------------
module "web_servers" {
  source = "../../modules/ec2"

  environment  = var.environment
  servers_name = var.servers_name
  ami_id       = var.ami_id
  region       = var.region
  key_pair     = var.key_pair
  subnet_id    = module.vpc.public_subnet_ids[0]
  vpc_id       = module.vpc.vpc_id

  ports = [
    { from_port = 22, to_port = 22, cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 80, to_port = 80, cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 443, to_port = 443, cidr_blocks = ["0.0.0.0/0"] },
  ]
}
