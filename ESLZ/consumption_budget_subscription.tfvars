# ESLZ/consumption_budget_subscription.tfvars
# Rules: existing entries unchanged; new args go below, commented out with explanation

consumption_budget_subscription = {
  # --- EXAMPLE ENTRY ---
  example = {
    env               = "Dev"
    group             = "OPS"
    project           = "CORE"
    userDefinedString = "budget01"
    subscription_id   = "00000000-0000-0000-0000-000000000000"

    budget = {
      budget_amount = 1000
      time_grain    = "Monthly"

      # name = "" # Optional: Override the auto-generated budget name (default: {env}-{group}-{project}-{userDefinedString}-budget)

      # time_period.end_date is optional; when omitted the provider defaults to 10 years after start_date
      # time_period = {
      #   end_date = "2032-06-01T00:00:00Z"
      # }

      contact_emails = ["foo@example.com", "bar@example.com"]

      notification = {
        actual_90 = {
          operator  = "EqualTo"
          threshold = 90
          # contact_emails = ["override@example.com"] # Optional: override the top-level contact_emails for this notification
          contact_groups = []
          contact_roles  = ["Owner"]
        }
        forecasted_100 = {
          operator       = "GreaterThan"
          threshold      = 100
          threshold_type = "Forecasted"
          enabled        = false
        }
      }

      # filter = {
      #   dimension = {
      #     rg = {
      #       name   = "ResourceGroupName"
      #       values = ["example-rg"]
      #     }
      #   }
      #   tag = {
      #     costcenter = {
      #       name   = "CostCenter"
      #       values = ["1234"]
      #     }
      #   }
      # }
    }
  }
}
