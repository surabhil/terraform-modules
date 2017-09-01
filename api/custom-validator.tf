# get information about the authorizer function from S3
data aws_s3_bucket_object "auth_public_keys"{
  count = "${length(var.authorizers)}"

  bucket = "${var.config_bucket}"
  key = "keys/authorizers/${element(var.authorizers, count.index)}/pubkey.pem"
}

module "custom_validator" {
  source = "../custom-validator"

  config_bucket = "${var.config_bucket}"

  validator_name = "${var.api_name}_validator"

  validator_environment_variables = "${merge(var.validator_environment_variables, zipmap(var.authorizers, data.aws_s3_bucket_object.auth_public_keys.*.body), map("api", var.api_name))}"
}

# create a new custom authorizer on the new API Gateway with the invoke ARN found above
resource "aws_api_gateway_authorizer" "validator" {
  name                             = "${var.api_name}_validator"
  rest_api_id                      = "${aws_api_gateway_rest_api.api.id}"
  authorizer_uri                   = "${module.custom_validator.validator_invoke_arn}"
  authorizer_result_ttl_in_seconds = "0"
}

# allow this custom authorizer to be called from API Gateway to authorize incoming requests
resource "aws_iam_role" "validator_invocation_role" {
  name = "api_gateway_${var.api_name}_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "validator_invocation_policy" {
  name = "api_gateway_${var.api_name}_invocation_policy"
  role = "${aws_iam_role.validator_invocation_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${module.custom_validator.validator_arn}"
    }
  ]
}
EOF
}
