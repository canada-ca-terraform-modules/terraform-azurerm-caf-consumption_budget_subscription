output "budget-object" {
  description = "Outputs the entire budget object"
  value = azurerm_consumption_budget_subscription.budget
}

output "budget-id" {
  description = "Outputs the ID of the budget"
  value = azurerm_consumption_budget_subscription.budget.id
}

output "budget-etag" {
  description = "Outputs the ETag of the budget"
  value = azurerm_consumption_budget_subscription.budget.etag
}