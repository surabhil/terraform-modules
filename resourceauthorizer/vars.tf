variable "config_bucket" {}

variable "authorizer_name" {}

variable "authorizer_filename" {}

variable "environment_variables" {
  type = "map"

  default = {
    key = "value"
  }
}
