variable "aws_region" {}

variable "config_bucket" {}

variable "resource_name" {}

variable "resource_path" {}

variable "authorizer_name" {}

variable "environment_variables" {
  type = "map"

  default = {
    key = "value"
  }
}

variable "custom_resource_parent_boolean" {
  default = false
}

variable "custom_resource_parent_id" {
  default = "noparent"
}
