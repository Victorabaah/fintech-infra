# Data block to fetch the latest Ubuntu AMI if ami_id is not provided.
data "aws_ami" "ubuntu_latest" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["746669221620"] # Canonical's owner ID for Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Local variable that selects either the provided ami_id or the one fetched above.
locals {
  final_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu_latest[0].id
}


locals {
  common_tags = merge(var.tags, {
    env_name = var.env_name
  })
}
