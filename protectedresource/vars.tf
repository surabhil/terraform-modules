variable "aws_region" {}

variable "config_bucket" {}

variable "api_name" {}

variable "names" {
  type = list
}

variable "environment_variables" {}

variable "paths" {
  type = list
}

variable "methods" {
  type = list
}

variable "parent_ids" {
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
