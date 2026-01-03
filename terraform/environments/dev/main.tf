terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "kind-ephemeral-dev"
}

module "preview_env" {
  source = "../../modules/preview-env"

  pr_number        = var.pr_number
  environment_name = var.environment_name
  namespace        = var.namespace
  db_name          = var.db_name
  db_user          = var.db_user
  db_password      = var.db_password
}

output "namespace" {
  value = module.preview_env.namespace
}

output "db_connection_string" {
  value     = module.preview_env.db_connection_string
  sensitive = true
}
