# `test/live/` - live-test harness

A live, real-Azure-resource harness used by the `live-test` PR check (see
the [`live-test-actions`](https://github.com/canada-ca-terraform-modules/live-test-actions)
repo and this module's own `.github/workflows/live-test.yml`) to prove that
an open PR doesn't destroy or replace a resource a real consumer already
has running. It is **not** a substitute for either of the module's other two
test surfaces:

- **`tests/*.tftest.hcl`** - mock-based unit tests (`terraform test`, no
  provider credentials, no live Azure resources). Covers naming, defaults,
  and validation logic on every PR via `terraform-ci.yml`. Run these first;
  they're fast and free.
- **`ESLZ/`** - a usage example showing the map-based (`for_each`) blueprint
  pattern consumers actually wire this module into. Not exercised by CI at
  all; documentation only.
- **`test/live/`** (this directory) - a single, real instance of the module
  applied against a disposable Azure sandbox subscription. Used by CI to
  diff the PR's plan against a live baseline, and can be run manually by a
  maintainer the same way.

## What's here

| File | Purpose |
|---|---|
| `main.tf` | Module block with `source = "../../"` (a relative path, not a pinned `?ref` - "baseline" and "PR" are just two on-disk checkouts of this repo), the `azurerm` provider config, and an empty `backend "local" {}` block (path supplied at `init` time - see below). |
| `variables.tf` | `env`, `group`, `project` (all default to `"livetest"`), `tags`, `pr_number` (defaults to `"manual"`), and `budget` (typed `any`, passed straight through to the module). |
| `config/consumption_budget_subscription.tfvars` | One representative real-usage fixture: a monthly budget with a single 90%-threshold notification. |

**No `test_dependencies.tf`** - unlike most other modules' harnesses, this
one deploys no throwaway resource group or other dependency. The module
under test (`azurerm_consumption_budget_subscription`) is subscription-scoped
and non-invasive: it can't affect any other resource in the subscription it
targets, so there's nothing here for a dedicated dependency resource to
isolate it from. Concurrency isolation between simultaneously open PRs is
handled instead by folding `var.pr_number` into the module's own
`userDefinedString` input (see `main.tf`), which feeds directly into the
generated budget name.

No Terragrunt anywhere under this directory - a single harness per repo has
no cross-harness DRY need.

## Running it manually

Requires your own `az login` session against the sandbox subscription (CI
uses OIDC instead).

```bash
cd test/live
terraform init
terraform plan  -var-file=config/consumption_budget_subscription.tfvars
terraform apply -var-file=config/consumption_budget_subscription.tfvars
```

Confirm only `module.consumption_budget_subscription` is planned/applied,
then tear it down:

```bash
terraform destroy -var-file=config/consumption_budget_subscription.tfvars
```

No `.tfstate` file is ever committed under `test/live/` - every run is
fully ephemeral, whether run by CI or by hand.

## Two-checkout state isolation (baseline vs. PR)

CI proves a PR isn't a breaking change by applying the target branch as a
live baseline, then plan/apply-ing the PR branch's checkout of this same
harness against that same live state - two on-disk checkouts of this repo,
one shared external state file, no state copying between them:

```bash
# Directory A: PR branch checkout, directory B: target branch checkout.
STATE=$RUNNER_TEMP/live-test-<pr-number>.tfstate

# 1. Baseline apply, from B.
cd B/test/live
terraform init -backend-config="path=$STATE"
terraform apply -var-file=config/consumption_budget_subscription.tfvars -var="pr_number=<pr-number>"

# 2. PR plan (and, in CI, apply), from A, against the same state file.
cd A/test/live
terraform init -backend-config="path=$STATE"
terraform plan -var-file=config/consumption_budget_subscription.tfvars -var="pr_number=<pr-number>"

# 3. Always tear down from A once the run finishes (`if: always()` in CI).
terraform destroy -var-file=config/consumption_budget_subscription.tfvars -var="pr_number=<pr-number>"
```

`pr_number` (`TF_VAR_pr_number` in CI, sourced from `github.event.number`)
is folded into the budget's `userDefinedString`, so two concurrently open
PRs against this module - each pointed at their own
`live-test-<pr-number>.tfstate` - never collide on the same sandbox
subscription's budget name.

To verify this locally without CI: check out this branch into two
directories, run step 1 from one and step 2 from the other against a
shared local state file path, and confirm the plan in step 2 diffs against
the resource step 1 actually created (not an empty/fresh-state plan).
Repeat with two different `pr_number` values and confirm no budget-name
collision in the sandbox subscription.
