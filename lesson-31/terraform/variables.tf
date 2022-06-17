variable "aws_region" {
  description = "AWS Region"
  default     = "eu-north-1"
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
  description = "Prefix of the deployment"
  type        = string
  default     = "demo"
}
