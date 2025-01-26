variable "cron" {}
variable "description" {}
variable "enable" { default = "ENABLED" }
variable "lambda_code" {}
variable "lambda_code_hash" {}
variable "handler" {}
variable "name" {}
variable "lambda_timeout" {
  default = "300"
}
variable "lambda_variables" { type = map() }
variable "role_arn" {}
variable "role_name" { default = "" }
variable "runtime" {}