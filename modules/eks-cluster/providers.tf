
provider "aws" {
  region = "us-east-2"
}


# provider "kubernetes" {
#   alias = "eks"
#   host  = module.eks_cluster.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
#   }
# }


# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.main.token
# }


# data "aws_eks_cluster" "this" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster_auth" "this" {
#   name = var.cluster_name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.this.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#   # token                  = data.aws_eks_cluster_auth.this.token
# }

