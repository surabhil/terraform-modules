variable "aws_region" {
  description = "what region to create the API in"
}

variable "config_bucket" {
  description = "what bucket to read/write configs to (needs to be apim-configs for now)"
}

variable "api_name" {
  description = "what name to give the API. for the moment, it will also be used like this: test.api.market/api_name"
}

variable "authorizers" {
  description = "a list of authorizers that the API call validators will accept. currently, only auth_1 exists"
  type = "list"
}

# the following 4 lists must all have the same length!
variable "names" {
  description = "a list of names of lambda functions to be created. there must be a corresponding file name.js"
  type = "list"
}

variable "paths" {
  description = "a list of paths to be created from each lambda. useful for mapping name.js to api_name/anothername"
  type = "list"
}

# use ANY if you want to support GET and POST, for example
variable "methods" {
  description = "a list of methods each path above should accept. each list element must be a string, not a list"
  type = "list"
}

variable "validations" {
  description = "a list of validations to use. each element can either be NONE (unprotected) or CUSTOM (protected)"
  type = "list"
}

variable "environment_variables" {
  description = "a map of environment variables that ALL lambdas on the API will be instantiated with"
  type = "map"

  default = {
    key = "value"
  }
}

variable "validator_environment_variables" {
  description = "a map of environment variables that the API's validator will be instantiated with (eg naive = 'true')"
  type = "map"

  default = {
    key = "value"
  }
}
