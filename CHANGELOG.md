# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.0] - 2026-08-04

### Added

- `providers.tf` pinning `azurerm ~> 5.0` and `required_version >= 1.9`.
- `budget.name` optional override for the auto-generated budget name (Pattern 12).
- `budget.time_period.end_date` optional argument (provider defaults to 10 years after `start_date` when omitted).
- Per-notification `contact_emails` override, falling back to the existing top-level `budget.contact_emails` when omitted — no change for existing tfvars.
- `ESLZ/consumption_budget_subscription.tf` and `ESLZ/consumption_budget_subscription.tfvars` — module block and example tfvars for L2 callers.
- `tests/consumption_budget_subscription.tftest.hcl` and `tests/upgrade_compat.tftest.hcl` — mock_provider test coverage.
- `.tflint.hcl`, `.gitignore`, `.gitattributes`.
- `.github/workflows/terraform-ci.yml` (fmt/init/validate/test/tflint) and `.github/workflows/release.yml` (tag-on-merge release).

### Changed

- `output.budget-object` marked `sensitive = true` (full resource object exposure).
- Bumped `.github/workflows/documentation.yaml` action pins (`actions/checkout` v4.1.7 → v7.0.1, `terraform-docs/gh-actions` v1.2.0 → v1.4.1).

### Fixed

- `filter` dynamic block iterated over `var.budget.filter` as if it were a map keyed by `dimension`/`tag`, which silently produced zero `dimension`/`tag` entries in the rendered filter for any caller-supplied filter. Fixed to treat `budget.filter` as a single optional object (`for_each = try(var.budget.filter, null) != null ? [var.budget.filter] : []`), matching how `dimension`/`tag` are read inside it.

### Known blockers

- None. Target provider `azurerm` pinned to `~> 5.0` (verified against `v5.0.1` release docs).
