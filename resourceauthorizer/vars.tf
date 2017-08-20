variable "config_bucket" {}

variable "authorizer_name" {}

variable "environment_variables" {
  type = "map"

  default = {
    key = "value"
  }
}
