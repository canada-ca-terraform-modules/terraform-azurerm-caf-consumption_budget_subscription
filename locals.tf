locals {
  current_timestamp = timestamp()
  current_year_month = formatdate("YYYY-MM", local.current_timestamp)
  first_day_current_month = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", "${local.current_year_month}-01T00:00:00Z")
  full_sub_id = "/subscriptions/${var.subscription_id}"
}