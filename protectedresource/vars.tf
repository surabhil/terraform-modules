variable "aws_region" {}

variable "resource_name" {
  description = "The name of the resource to be protected"
}

variable "environment_variables" {
  type = "map"
  default = {
    key = "value"
  }
}

variable "authorizer_name" {}
variable "authorizer_arn" {}
variable "authorizer_invoke_arn" {}
