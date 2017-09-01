variable "config_bucket" {}

variable "validator_name" {}

variable "validator_filename" {
  default = "validator"
}

variable "validator_environment_variables" {
  type = "map"
}
