
# ################################################################################
# # Default Variables
# ################################################################################

variable "main-region" {
  type    = string
  default = "us-east-2"
}


# ################################################################################
# # EKS Cluster Variables
# ################################################################################

variable "cluster_name" {
  type    = string
  default = "prod-dominion-cluster"
}

variable "rolearn" {
  description = "Add admin role to the aws-auth configmap"
  default     = "arn:aws:iam::746669221620:role/terraform-create-role"
}

# ################################################################################
# # ALB Controller Variables
# ################################################################################

variable "env_name" {
  type    = string
  default = "prod"
}



variable "tags" {
  description = "Common tags for the cluster resources"
  type        = map(string)
  default = {
    product   = "fintech-app"
    ManagedBy = "terraform"
  }
}


# EKS CLIENT NODE VARIABLE
variable "ami_id" {
  description = "The AMI ID for the Terraform node. Leave empty to automatically fetch the latest Ubuntu AMI."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The instance type for the Terraform node"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "The key name for the instance"
  type        = string
  default     = "privatekey38"
}

#Amazon Certificate Manager
variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
  default     = "greenashis.com"
}

variable "san_domains" {
  description = "Subject alternative names for the certificate"
  type        = list(string)
  default     = ["*.greenashis.com"]
}

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
  default     = "Z08744391SVSVTKX0BZ6P" # Replace with actual Route 53 Zone ID
}


##ECR

variable "aws_account_id" {
  description = "AWS Account ID"
  default     = "746669221620"
}

variable "repositories" {
  description = "List of ECR repositories to create"
  type        = list(string)
  default     = ["fintech-app"]
}

#### iam ###

variable "namespaces" {
  description = "Map of namespace definitions"
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





################################################################################
# EKS Cluster Variables for grafana and prometheus deployment
################################################################################

# variable "cluster_endpoint" {
#   type        = string
#   sensitive   = true
#   description = "The cluster endpoint"
# }

# variable "cluster_certificate_authority_data" {
#   type        = string
#   sensitive   = true
#   description = "The Cluster certificate data"
# }

# variable "oidc_provider_arn" {
#   description = "OIDC Provider ARN used for IRSA "
#   type        = string
#   sensitive   = true
# }

# ################################################################################
# # VPC Variables
# ################################################################################

# variable "vpc_id" {
#   description = "VPC ID which Load balancers will be  deployed in"
#   type        = string
# }

# variable "private_subnets" {
#   description = "A list of private subnets"
#   type        = list(string)
# }

################################################################################
# AWS SSO Variables
################################################################################

# variable "sso_admin_group_id" {
#   description = "AWS_SSO Admin Group ID"
#   type        = string
#   sensitive   = true
#   default     = "b4f8f4f8-e011-7046-0637-993dc10edd76"
# }


