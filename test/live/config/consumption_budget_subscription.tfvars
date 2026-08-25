# config/consumption_budget_subscription.tfvars
# Tracked, ready-to-run fixture for the test/live harness - one representative
# real-usage instance, not a two-code-path engineered fixture and not a
# dormant "_" template.
#
# env/group/project/userDefinedString are left to the harness's own
# variables.tf defaults (pr_number is folded into userDefinedString there) -
# only the module's own `budget` input needs a fixture value here.

budget = {
  budget_amount  = 100
  contact_emails = ["live-test@example.com"]

  notification = {
    actual_90 = {
      operator  = "EqualTo"
      threshold = 90
    }
  }
}
