variable "aws_region" {}

variable "config_bucket" {}

variable "api_name" {}

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

variable "environment_variables" {
  type = "map"

  default = {
    key = "value"
  }
}

variable "auth_environment_variables" {
  type = "map"

  default = {
    key = "value"
  }
}
