variable "resource_name" {
  description = "The name of the resource to be protected"
}

variable "authorizer_name" {
  description = "The name of the authorizer protecting the resource"
  default = "authorizer"
}