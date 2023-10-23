variable "aws_region" {
  description = "AWS Region."
  default     = "eu-west-1"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags for AWS that will be attached to each resource."
  default = {
    "TerminationDate" = "Permanent",
    "Environment"     = "Development",
    "Team"            = "DevOps",
    "DeployedBy"      = "Terraform",
    "OwnerEmail"      = "devops@example.com"
  }
}

variable "deployment_prefix" {
  description = "Prefix of the deployment."
  type        = string
  default     = "demo"
}

variable "gitlab_token" {
  type        = string
  sensitive   = true
  description = "The OAuth2 Token, Project, Group, Personal Access Token or CI Job Token used to connect to GitLab. The OAuth method is used in this provider for authentication (using Bearer authorization token)."
}
