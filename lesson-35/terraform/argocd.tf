provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
}

data "aws_route53_zone" "zone" {
  name         = local.hosted_zone
  private_zone = false
}

locals {
  hosted_zone = "kubxr.com"
  argocd = {
    gitlab_private_repo_name = "bakavets/k8s-demo"
    version                  = "5.4.0"
    namespace                = "argocd"
  }
  initial_bootstrap = {
    namespace      = "argocd",
    path           = "k8s/infrastructure/applications/",
    repoURL        = "git@gitlab.com:${local.argocd.gitlab_private_repo_name}.git",
    targetRevision = "main",
    acme_email     = "bakavets.com@gmail.com"
  }
}

# ED25519 key for ArgoCD
resource "tls_private_key" "ed25519_argocd" {
  algorithm = "ED25519"
}

resource "gitlab_deploy_key" "k8s_repo" {
  project = local.argocd.gitlab_private_repo_name
  title   = "ArgoCD Deploy key for deployment related to ${var.deployment_prefix}"
  key     = tls_private_key.ed25519_argocd.public_key_openssh
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = local.argocd.version
  namespace        = local.argocd.namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      k8s_ssh_private_key = tls_private_key.ed25519_argocd.private_key_openssh,
      k8s_repo            = local.argocd.gitlab_private_repo_name,
      host                = local.hosted_zone
    })
  ]

  depends_on = [
    module.eks
  ]
}

##################### Deploy initial bootstrap ArgoCD app #####################

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

resource "kubectl_manifest" "initial_bootstrap" {
  yaml_body = templatefile("${path.module}/templates/argocd-initial-bootstrap.yaml", {
    namespace      = local.argocd.namespace,
    path           = local.initial_bootstrap.path,
    repoURL        = local.initial_bootstrap.repoURL,
    targetRevision = local.initial_bootstrap.targetRevision,

    aws_region               = var.aws_region,
    aws_route53_dnsZone      = local.hosted_zone
    aws_route53_hostedZoneID = data.aws_route53_zone.zone.zone_id

    clusterName = module.eks.cluster_id,

    source_repoURL        = local.initial_bootstrap.repoURL,
    source_targetRevision = local.initial_bootstrap.targetRevision,

    bootstrapApp_certManager_serviceAccountName      = local.cert_manager.service_account_name,
    bootstrapApp_certManager_serviceAccountNamespace = local.cert_manager.namespace,
    bootstrapApp_certManager_eksRoleArn              = module.irsa_cert_manager.iam_role_arn,

    bootstrapApp_certManagerConfigs_acme_email = local.initial_bootstrap.acme_email,

    bootstrapApp_awsLBController_serviceAccountName = local.aws_load_balancer_controller.service_account_name,
    bootstrapApp_awsLBController_namespace          = local.aws_load_balancer_controller.namespace,
    bootstrapApp_awsLBController_eksRoleArn         = module.irsa_aws_load_balancer_controller.iam_role_arn,

    bootstrapApp_externalDNS_serviceAccountName = local.external_dns.service_account_name,
    bootstrapApp_externalDNS_namespace          = local.external_dns.namespace,
    bootstrapApp_externalDNS_eksRoleArn         = module.irsa_external_dns.iam_role_arn
  })

  depends_on = [
    helm_release.argocd,
    gitlab_deploy_key.k8s_repo
  ]
}
