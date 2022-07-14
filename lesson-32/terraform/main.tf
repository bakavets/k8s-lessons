terraform {
  required_version = ">= 1.0.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}

locals {
  cluster_name = "${var.deployment_prefix}-eks-cluster"
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.26.3"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.22"
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  tags = {
    "Name"            = "${local.cluster_name}"
    "Type"            = "Kubernetes Service"
    "K8s Description" = "Kubernetes for deployment related to ${var.deployment_prefix}"
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    management = {
      min_size     = 2
      max_size     = 5
      desired_size = 2

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      source_cluster_security_group = true
      description                   = "Allow workers pods to receive communication from the cluster control plane."
    }
    ingress_self_all = {
      description = "Allow nodes to communicate with each other (all ports/protocols)."
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress."
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

resource "aws_acm_certificate" "kubxr" {
  domain_name       = "app-2.kubxr.com"
  validation_method = "DNS"
}

resource "aws_route53_record" "acm" {
  for_each = {
    for kbxr in aws_acm_certificate.kubxr.domain_validation_options : kbxr.domain_name => {
      name   = kbxr.resource_record_name
      record = kbxr.resource_record_value
      type   = kbxr.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = "Z04182373OABFAT240LL1"
}

resource "aws_acm_certificate_validation" "es" {
  certificate_arn         = aws_acm_certificate.kubxr.arn
  validation_record_fqdns = [for record in aws_route53_record.acm : record.fqdn]
}