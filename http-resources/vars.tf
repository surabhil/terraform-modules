variable "aws_region" {}

variable "rest_api_id" {}

variable "rest_api_root_resource_id" {}

variable "validator_id" {}

variable "names" {
  type = "list"
}

variable "paths" {
  type = "list"
}

variable "methods" {
  type = "list"
}

variable "parent_ids" {
  type = "list"
}

variable "validations" {
  type = "list"
}

variable "lambda_arns" {
  type = "list"
}
