variable "aws_region" {}

variable "config_bucket" {}

variable "resource_name" {}

variable "resource_path" {}

variable "authorizer_name" {}

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
