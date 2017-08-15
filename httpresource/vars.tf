variable "aws_region" {}

variable "rest_api_id" {}

variable "rest_api_root_resource_id" {}

variable "authorizer_id" {
  default = ""
}

variable "resource_lambda_arn" {}

variable "resource_path" {}

variable "resource_method" {
  default = "ANY"
}

variable "custom_resource_parent_id" {
  default = ""
}
