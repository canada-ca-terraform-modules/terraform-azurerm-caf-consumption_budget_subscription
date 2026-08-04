mock_provider "azurerm" {}

variables {
  env               = "Dev"
  group             = "OPS"
  project           = "CORE"
  userDefinedString = "budget01"
  subscription_id   = "00000000-0000-0000-0000-000000000000"
}

run "naming_convention" {
  command = plan

  variables {
    budget = {
      budget_amount = 1000
      notification = {
        actual_90 = {
          operator  = "EqualTo"
          threshold = 90
        }
      }
      contact_emails = ["foo@example.com"]
    }
  }

  assert {
    condition     = azurerm_consumption_budget_subscription.budget.name == "Dev-OPS-CORE-budget01-budget"
    error_message = "Name must follow {env}-{group}-{project}-{userDefinedString}-budget convention"
  }

  assert {
    condition     = azurerm_consumption_budget_subscription.budget.subscription_id == "/subscriptions/00000000-0000-0000-0000-000000000000"
    error_message = "subscription_id must be normalized to full ARM resource ID"
  }
}

run "default_values" {
  command = plan

  variables {
    budget = {
      budget_amount = 500
      notification = {
        actual_90 = {
          operator  = "EqualTo"
          threshold = 90
        }
      }
      contact_emails = ["foo@example.com"]
    }
  }

  assert {
    condition     = azurerm_consumption_budget_subscription.budget.time_grain == "Monthly"
    error_message = "time_grain must default to Monthly"
  }

  assert {
    condition     = tolist(azurerm_consumption_budget_subscription.budget.notification)[0].threshold_type == "Actual"
    error_message = "threshold_type must default to Actual"
  }

  assert {
    condition     = tolist(azurerm_consumption_budget_subscription.budget.notification)[0].enabled == true
    error_message = "enabled must default to true"
  }

  assert {
    condition     = tolist(azurerm_consumption_budget_subscription.budget.notification)[0].contact_emails[0] == "foo@example.com"
    error_message = "notification must fall back to top-level contact_emails when not overridden"
  }
}

run "custom_name_override" {
  command = plan

  variables {
    budget = {
      name          = "existing-prod-budget"
      budget_amount = 500
      notification = {
        actual_90 = {
          operator  = "EqualTo"
          threshold = 90
        }
      }
      contact_emails = ["foo@example.com"]
    }
  }

  assert {
    condition     = azurerm_consumption_budget_subscription.budget.name == "existing-prod-budget"
    error_message = "budget.name override must take priority over the generated name"
  }
}

run "end_date_optional" {
  command = plan

  variables {
    budget = {
      budget_amount = 500
      time_period = {
        end_date = "2032-06-01T00:00:00Z"
      }
      notification = {
        actual_90 = {
          operator  = "EqualTo"
          threshold = 90
        }
      }
      contact_emails = ["foo@example.com"]
    }
  }

  assert {
    condition     = azurerm_consumption_budget_subscription.budget.time_period[0].end_date == "2032-06-01T00:00:00Z"
    error_message = "time_period.end_date must be passed through when supplied"
  }
}

run "notification_contact_emails_override" {
  command = plan

  variables {
    budget = {
      budget_amount  = 500
      contact_emails = ["default@example.com"]
      notification = {
        actual_90 = {
          operator       = "EqualTo"
          threshold      = 90
          contact_emails = ["override@example.com"]
        }
        forecasted_100 = {
          operator       = "GreaterThan"
          threshold      = 100
          threshold_type = "Forecasted"
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_consumption_budget_subscription.budget.notification) == 2
    error_message = "both notification blocks must be rendered"
  }
}

run "filter_dimension_and_tag" {
  command = plan

  variables {
    budget = {
      budget_amount = 500
      notification = {
        actual_90 = {
          operator  = "EqualTo"
          threshold = 90
        }
      }
      contact_emails = ["foo@example.com"]
      filter = {
        dimension = {
          rg = {
            name   = "ResourceGroupName"
            values = ["example-rg"]
          }
        }
        tag = {
          costcenter = {
            name   = "CostCenter"
            values = ["1234"]
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_consumption_budget_subscription.budget.filter) == 1
    error_message = "exactly one filter block must be rendered when budget.filter is set"
  }

  assert {
    condition     = tolist(tolist(azurerm_consumption_budget_subscription.budget.filter)[0].dimension)[0].values[0] == "example-rg"
    error_message = "filter.dimension values must be passed through"
  }

  assert {
    condition     = tolist(tolist(azurerm_consumption_budget_subscription.budget.filter)[0].tag)[0].values[0] == "1234"
    error_message = "filter.tag values must be passed through"
  }
}

run "no_filter" {
  command = plan

  variables {
    budget = {
      budget_amount = 500
      notification = {
        actual_90 = {
          operator  = "EqualTo"
          threshold = 90
        }
      }
      contact_emails = ["foo@example.com"]
    }
  }

  assert {
    condition     = length(azurerm_consumption_budget_subscription.budget.filter) == 0
    error_message = "no filter block must be rendered when budget.filter is absent"
  }
}
