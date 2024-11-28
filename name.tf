locals {
  anti-pattern-regex = "/[//\"'\\[\\]:|<>+=;,?*@&]/"
  budget-name = replace("${var.env}-${var.group}-${var.project}-${var.userDefinedString}-budget", local.anti-pattern-regex, "")
}