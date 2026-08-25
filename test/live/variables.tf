variable "env" {
  description = "Environment prefix used in the generated budget name"
  type        = string
  default     = "livetest"
}

variable "group" {
  description = "Group value used in the generated budget name"
  type        = string
  default     = "livetest"
}

variable "project" {
  description = "Project value used in the generated budget name"
  type        = string
  default     = "livetest"
}

variable "tags" {
  description = "Tags applied to the budget created by this harness"
  type        = map(string)
  default = {
    purpose = "module-live-test"
  }
}

variable "pr_number" {
  description = <<-EOT
    Suffix folded into the budget's userDefinedString so concurrent PRs
    against this module never collide on the same sandbox subscription (this
    module has no throwaway resource group of its own to suffix instead). CI
    sources this from `TF_VAR_pr_number` (`github.event.number`); manual runs
    can leave the default or pass their own value.
  EOT
  type        = string
  default     = "manual"
}

variable "budget" {
  description = "Consumption budget configuration object, passed straight through to the module under test"
  type        = any
}
