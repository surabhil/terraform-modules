variable "aws_region" {}

variable "config_bucket" {}

variable "api_name" {}

variable "resources" {
  type = list
}

variable "authorizer_name" {}

//variable "environment_variables" {
//  type = "map"
//
//  default = {}
//}
//
//variable "resource_method" {
//  default = "ANY"
//}
//
//variable "resource_parent_id" {
//  default = ""
//}
