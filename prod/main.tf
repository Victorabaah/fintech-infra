# ################################################################################
# # VPC Module
# ################################################################################

module "vpc" {
  source      = "./../modules/vpc"
  main_region = var.main_region
}

# ################################################################################
# # EKS Cluster Module
# ################################################################################

module "eks" {
  source = "./../modules/eks-cluster"

  cluster_name = var.cluster_name
  rolearn      = var.rolearn
  cni_role_arn = module.iam.cni_role_arn

  security_group_ids = [module.eks-client-node.eks_client_sg]
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets

  # Enables EKS to bootstrap and manage the core addons

  tags     = local.common_tags
  env_name = var.env_name
}



# ################################################################################
# # AWS ALB Controller
# ################################################################################

module "aws_alb_controller" {
  source = "./../modules/aws-alb-controller"

  main_region       = var.main_region
  cluster_name      = var.cluster_name
  vpc_id            = module.vpc.vpc_id
  account_id        = var.aws_account_id
  oidc_provider_arn = module.eks.oidc_provider_arn

  depends_on = [module.eks]
}


module "eks-client-node" {
  source                 = "./../modules/eks-client-node"
  ami_id                 = local.final_ami_id
  instance_type          = var.instance_type
  aws_region             = var.main_region
  subnet_id              = module.vpc.public_subnets[0]
  vpc_id                 = module.vpc.vpc_id
  vpc_security_group_ids = [module.eks-client-node.eks_client_sg]
  cluster_name           = module.eks.cluster_name
  tags = {
    Name = "eks_client_node"
  }
  key_name = module.eks-client-node.eks_client_private_key
  user_data = base64encode(<<-EOF
  #!/bin/bash
  exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
  set -xe

  echo "Waiting for cloud-init to settle..."
  sleep 15

  echo "Updating system and installing prerequisites..."
  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unzip gnupg curl lsb-release software-properties-common \
    apt-transport-https ca-certificates

  echo "Installing AWS CLI v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -o awscliv2.zip
  ./aws/install

  echo "Installing Terraform..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
  apt-get update -y
  apt-get install -y terraform

  echo "Installing kubectl..."
  curl -LO https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.3/2024-12-12/bin/linux/amd64/kubectl
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

  echo "Installing Docker CE..."
  apt-get remove -y docker docker-engine docker.io containerd runc || true
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io

  echo "Enabling and starting Docker..."
  systemctl enable docker
  systemctl start docker

  echo "Adding 'ubuntu' user to 'docker' group..."
  usermod -aG docker ubuntu

  echo "Installing Amazon SSM Agent via deb package..."
  region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
  curl -o /tmp/ssm-agent.deb "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb"
  dpkg -i /tmp/ssm-agent.deb
  systemctl enable amazon-ssm-agent
  systemctl start amazon-ssm-agent

  echo "Setup complete. Rebooting..."
  reboot
EOF
  )

}



module "acm" {
  source          = "./../modules/acm"
  domain_name     = var.domain_name
  san_domains     = var.san_domains
  route53_zone_id = var.route53_zone_id
  tags            = local.common_tags
}


module "ecr" {
  source         = "./../modules/ecr"
  aws_account_id = var.aws_account_id
  repositories   = var.repositories
  tags           = local.common_tags
}

module "iam" {
  source            = "./../modules/iam"
  environment       = var.env_name
  aws_region        = var.aws_region
  aws_account_id    = var.aws_account_id
  eks_oidc_provider = local.eks_oidc_provider
  cluster_name      = var.cluster_name
  tags              = local.common_tags
}



##############################################
# EKS TOOLS
##############################################
# module "jenkins-server" {
#   source            = "./../modules/jenkins-server"
#   ami_id            = local.final_ami_id
#   instance_type     = var.instance_type
#   key_name          = var.key_name
#   main_region       = var.main_region
#   security_group_id = module.eks-client-node.eks_client_sg
#   subnet_id         = module.vpc.public_subnets[0]
# }


module "github-self-hosted-runner" {
  source            = "./../modules/github-self-hosted-runner"
  ami_id            = local.final_ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  main_region       = var.main_region
  security_group_id = module.eks-client-node.eks_client_sg
  subnet_id         = module.vpc.public_subnets[0]
  cluster_name      = module.eks.cluster_name
}

module "maven-sonarqube-server" {
  source            = "./../modules/maven-sonarqube-server"
  ami_id            = local.final_ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  security_group_id = module.eks-client-node.eks_client_sg
  subnet_id         = module.vpc.public_subnets[0]
  # main_region   = var.main_region

  #   db_name              = var.db_name
  #   db_username          = var.db_username
  #   db_password          = var.db_password
  #   db_subnet_group      = var.db_subnet_group
  #   db_security_group_id = var.db_security_group_id
}





# ################################################################################
# # Managed Grafana Module
# ################################################################################

# module "managed_grafana" {
#   source             = "./modules/grafana"
#   env_name           = var.env_name
#   main_region        = var.main_region
#   private_subnets    = module.vpc.private_subnets
#   sso_admin_group_id = var.sso_admin_group_id
# }



# # ################################################################################
# # # Managed Prometheus Module
# # ################################################################################

# module "prometheus" {
#   source            = "./modules/prometheus"
#   env_name          = var.env_name
#   main_region       = var.main_region
#   cluster_name      = var.cluster_name
#   oidc_provider_arn = module.eks.oidc_provider_arn
#   vpc_id            = module.vpc.vpc_id
#   private_subnets   = module.vpc.private_subnets
# }



# # ################################################################################
# # # VPC Endpoints for Prometheus and Grafana Module
# # ################################################################################

# module "vpcendpoints" {
#   source                    = "./modules/vpcendpoints"
#   env_name                  = var.env_name
#   main_region               = var.main_region
#   vpc_id                    = module.vpc.vpc_id
#   private_subnets           = module.vpc.private_subnets
#   grafana_security_group_id = module.managed_grafana.security_group_id
# }


