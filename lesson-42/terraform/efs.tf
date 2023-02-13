resource "aws_security_group" "app_efs" {
  name        = "${var.deployment_prefix}-efs-app-sg"
  description = "Inbound NFS traffic only from internal K8s Nodes within deployment: ${var.deployment_prefix} to interact with the k8s app EFS"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${var.deployment_prefix}-efs-app-sg"
  }
}

resource "aws_security_group_rule" "app" {
  type                     = "ingress"
  description              = "Inbound NFS traffic only from internal K8s Nodes within deployment: ${var.deployment_prefix} to interact with the k8s app EFS"
  security_group_id        = aws_security_group.app_efs.id
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_worker_node.id
}

resource "aws_efs_file_system" "app_fs" {
  creation_token   = "${var.deployment_prefix}-app"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  kms_key_id       = aws_kms_key.kms.arn
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
  tags = {
    "Name"       = "${var.deployment_prefix}-app"
    "Type"       = "File System Service"
    "K8sAppName" = "app"
  }
}

resource "aws_efs_mount_target" "app" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.app_fs.id
  subnet_id       = element(module.vpc.private_subnets, count.index)
  security_groups = [aws_security_group.app_efs.id]
}

resource "aws_efs_backup_policy" "app" {
  file_system_id = aws_efs_file_system.app_fs.id

  backup_policy {
    status = "DISABLED"
  }
}
