resource "azurerm_consumption_budget_subscription" "budget" {
  name = local.budget-name
  subscription_id = local.full_sub_id
  amount = var.budget.budget_amount

  time_grain = try(var.budget.time_grain, "Monthly")


  time_period {
    start_date = local.first_day_current_month
  }

  dynamic "notification" {
    for_each = var.budget.notification
    content {
      operator = notification.value["operator"]
      threshold   = notification.value["threshold"]
      contact_emails = var.budget.contact_emails
      threshold_type = try(notification.value["threshold_type"], "Actual")
      contact_groups = try(notification.value["contact_groups"], null)
      contact_roles = try(notification.value["contact_roles"], null)
      enabled = try(notification.value["enabled"], true)
    }
  }

  dynamic "filter" {
    for_each = try(var.budget.filter, {})
    content {
      dynamic "dimension" {
        for_each = try(filter.value.dimension, {})
        content {
          name = dimension.value.name
          values = dimension.value.values
          operator = try(dimension.value.operator, "In")
        }
      }
      dynamic "tag" {
        for_each = try(filter.value.tag, {})
        content {
          name = tag.value.name
          values = tag.value.values
          operator = try(tag.value.operator, "In")
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [ time_period[0].start_date ]
  }
}