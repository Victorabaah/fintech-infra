################################################################################
# General Variables
################################################################################

variable "main_region" {
  description = "AWS Region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
 }

 variable "account_id" {
  description = "aws account"
  default = 999568710647
   
 }
