terraform {
  required_version = ">= 1.0.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.70.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
  }
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

locals {
  cluster_name = "${var.deployment_prefix}-eks-cluster"
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "17.24.0"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.21"
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  write_kubeconfig                = false
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  tags = {
    "Name"            = "${local.cluster_name}"
    "Type"            = "Kubernetes Service"
    "K8s Description" = "Kubernetes for deployment related to ${var.deployment_prefix}"
  }
  worker_groups_launch_template = [
    {
      name                                     = "management-on-demand-node-group"
      override_instance_types                  = ["t3.medium"]
      root_volume_size                         = 40
      root_volume_type                         = "gp3"
      root_encrypted                           = true
      asg_min_size                             = 1
      asg_max_size                             = 2
      asg_desired_capacity                     = 1
      on_demand_percentage_above_base_capacity = 100
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`"
      additional_security_group_ids            = [aws_security_group.all_worker_node_groups.id]
      ami_id                                   = "ami-0bb38f97f38be3ee7" # Select appropriate AMI for your region https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
      enable_monitoring                        = false
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]
    }
  ]
}