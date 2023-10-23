locals {
  username               = "gitlab"
  db_name                = "gitlabhq_production"
  db_instance_identifier = "${var.deployment_prefix}-gitlab"
}

################################################################################
# SecretsManager Secret
################################################################################

resource "random_password" "master_password" {
  length           = 32
  min_lower        = 1
  min_numeric      = 3
  min_special      = 3
  min_upper        = 3
  special          = true
  numeric          = true
  upper            = true
  override_special = "!#$&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "gitlab" {
  name        = "${var.deployment_prefix}-gitlab-demo"
  description = "GitLab RDS Postgres credentials for ${var.deployment_prefix} environment."
  tags = {
    "Name" = "${var.deployment_prefix}-gitlab-demo"
    "Type" = "Secrets Manager"
  }
}

resource "aws_secretsmanager_secret_version" "gitlab" {
  secret_id = aws_secretsmanager_secret.gitlab.id
  secret_string = jsonencode({
    username               = local.username
    password               = random_password.master_password.result
    engine                 = module.gitlab.db_instance_engine
    dbname                 = local.db_name
    host                   = module.gitlab.db_instance_address
    port                   = module.gitlab.db_instance_port
    db_instance_identifier = local.db_instance_identifier
  })
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "gitlab" {
  name_prefix = "${var.deployment_prefix}-gitlab-rds-sg"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${var.deployment_prefix}-gitlab-rds-sg"
  }
}

resource "aws_security_group_rule" "access_ingress_from_kubernetes_nodes" {
  type                     = "ingress"
  description              = "Inbound traffic only from Kubernetes nodes"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = aws_security_group.gitlab.id
}

################################################################################
# RDS Module
################################################################################

module "gitlab" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier = local.db_instance_identifier

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = "db.t3.small"

  storage_type          = "gp3"
  allocated_storage     = 30
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name                     = local.db_name
  username                    = local.username
  manage_master_user_password = false
  password                    = random_password.master_password.result
  port                        = 5432
  multi_az                    = false
  publicly_accessible         = false
  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.gitlab.id]

  skip_final_snapshot              = false
  final_snapshot_identifier_prefix = "${local.db_instance_identifier}-final"

  auto_minor_version_upgrade = true
  maintenance_window         = "Mon:00:00-Mon:03:00"
  backup_retention_period    = 7
  backup_window              = "03:00-06:00"

  copy_tags_to_snapshot     = true
  deletion_protection       = false
  create_db_option_group    = false
  create_db_parameter_group = true

  parameters = [
    {
      name  = "rds.force_ssl"
      value = "1"
    }
  ]

  tags = {
    Name   = local.db_instance_identifier
    Type   = "Relational Database Service"
    Engine = "Postgres"
  }
}
