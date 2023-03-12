provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

locals {
  cluster_name = "${var.deployment_prefix}-eks-cluster"
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "19.10.0"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.25"
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://github.com/aws/amazon-vpc-cni-k8s/issues/493
          # Reference docs https://github.com/kubernetes/kubernetes/issues/39113
          # Reference docs https://github.com/aws/amazon-vpc-cni-k8s/pull/1629
          ANNOTATE_POD_IP = "true"
        }
      })
    }
  }

  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []

  manage_aws_auth_configmap = true
  create_kms_key = false
  cluster_encryption_config = {}
  
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
      labels = {
        "node.k8s/role" = "management"
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Allow nodes to communicate with each other (all ports/protocols)."
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }
}
