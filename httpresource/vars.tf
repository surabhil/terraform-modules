variable "aws_region" {}

variable "rest_api_id" {}

variable "rest_api_root_resource_id" {}

variable "authorizer_id" {
  default = ""
}

variable "request_parameters" {
  type = "map"
}

variable "resource_lambda_arn" {}

variable "resource_path" {}

variable "resource_method" {}

variable "resource_parent_id" {}
