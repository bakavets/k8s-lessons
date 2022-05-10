data "aws_availability_zones" "available" {}

module "vpc" {
  source                             = "terraform-aws-modules/vpc/aws"
  version                            = "3.11.0"
  name                               = "${var.deployment_prefix}-vpc"
  cidr                               = "10.23.0.0/16"
  azs                                = data.aws_availability_zones.available.names
  private_subnets                    = ["10.23.0.0/19", "10.23.32.0/19", "10.23.64.0/19"]
  public_subnets                     = ["10.23.96.0/22", "10.23.100.0/22", "10.23.104.0/22"]
  database_subnets                   = ["10.23.108.0/24", "10.23.109.0/24", "10.23.110.0/24"]
  intra_subnets                      = ["10.23.111.0/24", "10.23.112.0/24", "10.23.113.0/24"]
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  one_nat_gateway_per_az             = false
  enable_dns_hostnames               = true
  create_igw                         = true
  create_database_subnet_route_table = true
  tags = {
    "Name" = "${var.deployment_prefix}-VPC"
  }

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

  database_subnet_tags = {
    "Name" = "database-subnet-${var.deployment_prefix}"
  }

  intra_subnet_tags = {
    "Name" = "intra-subnet-${var.deployment_prefix}"
  }

  public_route_table_tags = {
    "Name" = "public-route-table-${var.deployment_prefix}"
  }

  private_route_table_tags = {
    "Name" = "private-route-table-${var.deployment_prefix}"
  }

  database_route_table_tags = {
    "Name" = "database-route-table-${var.deployment_prefix}"
  }

  intra_route_table_tags = {
    "Name" = "intra-route-table-${var.deployment_prefix}"
  }
}
