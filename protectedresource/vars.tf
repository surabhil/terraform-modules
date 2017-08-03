variable "aws_region" {}

variable "config_bucket" {}

variable "resource_name" {}

variable "authorizer_name" {}

variable "environment_variables" {
  type = "map"
  default = {
    key = "value"
  }
}
