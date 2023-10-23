module "s3_gitlab_artifacts" {
  source            = "./modules/s3"
  deployment_prefix = var.deployment_prefix
  deployment_suffix = "gitlab-artifacts-storage"
}

module "s3_gitlab_backups" {
  source            = "./modules/s3"
  deployment_prefix = var.deployment_prefix
  deployment_suffix = "gitlab-backups-storage"
}

module "s3_gitlab_lfs" {
  source            = "./modules/s3"
  deployment_prefix = var.deployment_prefix
  deployment_suffix = "gitlab-lfs-storage"
}

module "s3_gitlab_packages" {
  source            = "./modules/s3"
  deployment_prefix = var.deployment_prefix
  deployment_suffix = "gitlab-packages-storage"
}

module "s3_gitlab_tmp" {
  source            = "./modules/s3"
  deployment_prefix = var.deployment_prefix
  deployment_suffix = "gitlab-tmp-storage"
}

module "s3_gitlab_uploads" {
  source            = "./modules/s3"
  deployment_prefix = var.deployment_prefix
  deployment_suffix = "gitlab-uploads-storage"
}

module "s3_gitlab_pages" {
  source            = "./modules/s3"
  deployment_prefix = var.deployment_prefix
  deployment_suffix = "gitlab-pages-storage"
}

module "s3_gitlab_runners_cache" {
  source            = "./modules/s3"
  deployment_prefix = var.deployment_prefix
  deployment_suffix = "gitlab-runners-cache-storage"
}
