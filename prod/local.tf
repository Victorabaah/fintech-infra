# Fetch latest Ubuntu 20.04 AMI if ami_id not explicitly provided
data "aws_ami" "ubuntu_latest" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Combined locals
locals {
  # Use the provided AMI or fetch the latest Ubuntu 20.04
  final_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu_latest[0].id

  # Safely derive the OIDC provider URL after EKS is created
  eks_oidc_provider = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  # Combine base tags with env_name
  common_tags = merge(var.tags, {
    env_name = var.env_name
  })
}

