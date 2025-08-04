################################################################################
# Service Account for IRSA
################################################################################

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller.arn
    }
  }
}

################################################################################
# IAM Role for Service Account (IRSA)
################################################################################

resource "aws_iam_role" "lb_controller" {
  name = "${var.cluster_name}-aws-load-balancer-controller"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"

      # Correct: extract the URL path only, remove the ARN prefix
      variable = "${replace(var.oidc_provider_arn, "arn:aws:iam::${var.account_id}:oidc-provider/", "")}:sub"

      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

################################################################################
# Inline IAM Policy for ALB Controller (Official from AWS)
################################################################################

data "aws_iam_policy_document" "lb_controller_policy" {
  statement {
    effect = "Allow"

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:Describe*",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:*",
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "tag:GetResources",
      "tag:TagResources",
      "waf:GetWebACL",
      "waf:AssociateWebACL",
      "waf:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lb_controller_inline_policy" {
  name = "${var.cluster_name}-aws-load-balancer-policy"
  role = aws_iam_role.lb_controller.id
  policy = data.aws_iam_policy_document.lb_controller_policy.json
}

################################################################################
# Helm Release: AWS Load Balancer Controller
################################################################################

resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  create_namespace = true

  depends_on = [
    kubernetes_service_account.service_account,
    aws_iam_role.lb_controller
  ]

  set = [
    {
      name  = "region"
      value = var.main_region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "image.repository"
      value = "602401143452.dkr.ecr.${var.main_region}.amazonaws.com/amazon/aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.service_account.metadata[0].name
    },
    {
      name  = "clusterName"
      value = var.cluster_name
    }
  ]
}
