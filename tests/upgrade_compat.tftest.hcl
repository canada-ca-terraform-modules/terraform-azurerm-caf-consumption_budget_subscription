mock_provider "azurerm" {}

variables {
  env               = "Dev"
  group             = "OPS"
  project           = "CORE"
  userDefinedString = "budget01"
  subscription_id   = "00000000-0000-0000-0000-000000000000"
}

# Step 1: simulate the currently-deployed resource (pre-upgrade inputs only)
run "baseline_apply" {
  command = apply

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
    error_message = "Baseline apply: unexpected resource name"
  }
}

# Step 2: plan upgraded code (new optional args added) against that state
run "upgrade_plan_no_replacement" {
  command = plan

  variables {
    budget = {
      budget_amount = 1000
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
    condition     = azurerm_consumption_budget_subscription.budget.name == "Dev-OPS-CORE-budget01-budget"
    error_message = "Resource name must be unchanged after upgrade"
  }

  assert {
    condition     = azurerm_consumption_budget_subscription.budget.time_period[0].end_date == "2032-06-01T00:00:00Z"
    error_message = "new end_date argument must be set without triggering replacement"
  }
}
