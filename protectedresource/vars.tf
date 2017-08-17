variable "aws_region" {}

variable "config_bucket" {}

variable "resource_name" {}

variable "resource_path" {}

variable "authorizer_name" {}

variable "request_parameters" {
  type = "map"

  default = {}
}

variable "environment_variables" {
  type = "map"

  default = {}
}

variable "resource_method" {
  default = "ANY"
}

variable "resource_parent_id" {
  default = ""
}
