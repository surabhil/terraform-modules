variable "aws_region" {}

variable "config_bucket" {}

variable "api_name" {}

variable "authorizers" {
  type = "list"
}

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

  default = []
}

variable "validations" {
  type = "list"
}

variable "environment_variables" {
  type = "map"

  default = {
    key = "value"
  }
}

variable "validator_environment_variables" {
  type = "map"

  default = {
    key = "value"
  }
}
