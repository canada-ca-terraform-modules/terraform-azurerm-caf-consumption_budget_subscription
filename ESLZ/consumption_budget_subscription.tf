/*
ESLZ/consumption_budget_subscription.tf

Declares the variables consumed by the module block so callers can wire
their own var.* values in, and the module block itself.
*/

terraform {
  required_version = ">= 1.9"
}

variable "consumption_budget_subscription" {
  description = "Map of subscription consumption budget configuration objects"
  type        = any
  default     = {}
}

module "consumption_budget_subscription" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-consumption_budget_subscription?ref=v1.1.0"
  for_each = var.consumption_budget_subscription

  env               = each.value.env
  group             = each.value.group
  project           = each.value.project
  userDefinedString = each.value.userDefinedString
  subscription_id   = each.value.subscription_id
  tags              = try(each.value.tags, {})
  budget            = each.value.budget
}
