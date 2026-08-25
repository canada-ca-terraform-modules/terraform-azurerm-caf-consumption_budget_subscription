terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {}
}

# Subscription-scoped module - the budget lands in whatever subscription
# this provider authenticates against (the shared live-test sandbox in CI),
# so no subscription ID needs to be hardcoded here.
data "azurerm_subscription" "current" {}

module "consumption_budget_subscription" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  env     = var.env
  group   = var.group
  project = var.project
  # This module has no throwaway resource group of its own to suffix, so
  # pr_number is folded into userDefinedString instead - it feeds directly
  # into the generated budget name, keeping concurrent PRs from colliding.
  userDefinedString = "livetest-${var.pr_number}"
  subscription_id   = data.azurerm_subscription.current.subscription_id
  tags              = var.tags
  budget            = var.budget
}
