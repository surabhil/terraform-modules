variable "aws_region" {}

variable "rest_api_id" {}

variable "rest_api_root_resource_id" {}

variable "authorizer_id" {}

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

variable "authorization" {
  type = "list"
}

variable "lambda_arns" {
  type = "list"
}
