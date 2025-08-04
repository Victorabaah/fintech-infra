################################################################################
# General AWS Configuration
################################################################################

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "999568710647"
}

variable "aws_region" {
  description = "AWS Region used for deployments"
  type        = string
  default     = "us-east-2"
}

variable "main_region" {
  description = "Primary region for VPC and global resources"
  type        = string
  default     = "us-east-2"
}

################################################################################
# Environment and Tagging
################################################################################

variable "env_name" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    product   = "fintech-app"
    ManagedBy = "terraform"
  }
}

################################################################################
# EKS Cluster Configuration
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "prod-dominion-cluster"
}

variable "rolearn" {
  description = "IAM role ARN to be added to the aws-auth configmap as admin"
  type        = string
  default     = "arn:aws:iam::999568710647:role/terraform-create-role"
}


################################################################################
# EC2 / Client Node Configuration
################################################################################

variable "ami_id" {
  description = "AMI ID for client nodes (leave empty to auto-fetch latest Ubuntu)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type for EC2-based client nodes"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "class38_demo_key"
}

################################################################################
# Certificate Manager (ACM) & Route 53
################################################################################

variable "domain_name" {
  description = "Primary domain name for certificate issuance"
  type        = string
  default     = "dominionsystem.org"
}

variable "san_domains" {
  description = "SANs (Subject Alternative Names) for SSL certificate"
  type        = list(string)
  default     = ["*.dominionsystem.org"]
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for domain validation"
  type        = string
  default     = "Z05475331ZK00RPD27RX0"
}

################################################################################
# ECR Repositories
################################################################################

variable "repositories" {
  description = "List of ECR repositories to create"
  type        = list(string)
  default     = ["fintech-app","gateway"]
}

################################################################################
# Kubernetes Namespaces (for add-ons or app grouping)
################################################################################

variable "namespaces" {
  description = "Kubernetes namespace configurations with annotations and labels"
  type = map(object({
    annotations = map(string)
    labels      = map(string)
  }))
  default = {
    fintech = {
      annotations = {
        name = "fintech"
      }
      labels = {
        app = "webapp"
      }
    },
    monitoring = {
      annotations = {
        name = "monitoring"
      }
      labels = {
        app = "webapp"
      }
    }
  }
}
