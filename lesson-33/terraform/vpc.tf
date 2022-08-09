data "aws_availability_zones" "available" {}

module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "3.14.2"
  name                   = "${var.deployment_prefix}-VPC"
  cidr                   = "10.23.0.0/16"
  azs                    = data.aws_availability_zones.available.names
  private_subnets        = ["10.23.0.0/19", "10.23.32.0/19", "10.23.64.0/19"]
  public_subnets         = ["10.23.96.0/22", "10.23.100.0/22", "10.23.104.0/22"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true

  tags = {
    "Name" = "${var.deployment_prefix}-VPC"
  }

  # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/subnet_discovery/

  public_subnet_tags = {
    "Name"                                        = "public-subnet-${var.deployment_prefix}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "Name"                                        = "private-subnet-${var.deployment_prefix}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  public_route_table_tags = {
    "Name" = "public-route-table-${var.deployment_prefix}"
  }

  private_route_table_tags = {
    "Name" = "private-route-table-${var.deployment_prefix}"
  }
}
