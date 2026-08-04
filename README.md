# terraform-azurerm-caf-consumption_budget_subscription

Creates an `azurerm_consumption_budget_subscription` resource following the Government of Canada CAF naming and tagging convention.

## Usage

### ESLZ module block (`ESLZ/consumption_budget_subscription.tf`)

```hcl
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
```

### ESLZ tfvars pattern (`ESLZ/consumption_budget_subscription.tfvars`)

```hcl
consumption_budget_subscription = {
  example = {
    env               = "Dev"
    group             = "OPS"
    project           = "CORE"
    userDefinedString = "budget01"
    subscription_id   = "00000000-0000-0000-0000-000000000000"

    budget = {
      budget_amount  = 1000
      contact_emails = ["foo@example.com"]
      notification = {
        actual_90 = {
          operator  = "EqualTo"
          threshold = 90
        }
      }
    }
  }
}
```

## New arguments (azurerm ~> 5.0)

| Key | Type | Description |
|---|---|---|
| `budget.name` | string | Optional override for the auto-generated budget name |
| `budget.time_period.end_date` | string | Optional end date for the budget (defaults to 10 years after `start_date`) |
| `budget.notification.<key>.contact_emails` | list(string) | Optional per-notification override of the top-level `budget.contact_emails` |

## Testing

```bash
terraform fmt -recursive && terraform init -backend=false && terraform validate && terraform test
```

## CI

GitHub Actions workflow at `.github/workflows/terraform-ci.yml` runs fmt, init, validate, test, and tflint on every PR. `.github/workflows/release.yml` tags a GitHub release on merge to `main`, using the version pinned in `ESLZ/consumption_budget_subscription.tf`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 5.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_consumption_budget_subscription.budget](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_budget"></a> [budget](#input\_budget) | Object containing all parameters for the consumption budget | `any` | `{}` | no |
| <a name="input_env"></a> [env](#input\_env) | (Required) Env value for the name of the resource | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | (Required) Group value for the name of the resource | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | (Required) Project value for the name of the resource | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID for the target project | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Maps of tags that will be applied to the resource | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) UserDefinedString value for the name of the resource | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget-etag"></a> [budget-etag](#output\_budget-etag) | Outputs the ETag of the budget |
| <a name="output_budget-id"></a> [budget-id](#output\_budget-id) | Outputs the ID of the budget |
| <a name="output_budget-object"></a> [budget-object](#output\_budget-object) | Outputs the entire budget object |
<!-- END_TF_DOCS -->
