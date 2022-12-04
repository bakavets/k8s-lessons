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
  version                         = "18.26.6"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.23"
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []

  tags = {
    "Name"            = "${local.cluster_name}"
    "Type"            = "Kubernetes Service"
    "K8s Description" = "Kubernetes for deployment related to ${var.deployment_prefix}"
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    on_demand = {
      min_size     = 2
      max_size     = 5
      desired_size = 3

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

    spot_app_worker = {
      name         = "app-worker"
      min_size     = 2
      max_size     = 5
      desired_size = 4

      instance_types = ["m6i.xlarge", "m5.xlarge", "m5n.xlarge", "m5zn.xlarge"]
      capacity_type  = "SPOT"

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
        "node.k8s/role" = "app-worker"
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
