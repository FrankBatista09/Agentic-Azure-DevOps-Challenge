terraform {
  required_version = "~> 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.69"
    }
  }

  # Partial configuration: the CD pipeline supplies resource_group_name,
  # storage_account_name, container_name and key (one state file per
  # environment) through -backend-config, plus use_oidc.
  backend "azurerm" {
    use_azuread_auth = true
  }
}

# Subscription, tenant and client IDs come from the ARM_* environment
# variables set by the pipeline (OIDC). Nothing is hardcoded here.
provider "azurerm" {
  features {}
}
