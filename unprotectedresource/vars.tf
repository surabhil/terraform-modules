variable "aws_region" {}

variable "resource_name" {
  description = "The name of the resource to be protected"
}

variable "file_name" {}

variable "environment_variables" {
  type = "map"
  default = {
    key = "value"
  }
}