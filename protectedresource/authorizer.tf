data "aws_s3_bucket_object" "auth_fn_name" {
  bucket = "${var.config_bucket}"
  key = "${var.authorizer_name}/function_name"
}

data "aws_s3_bucket_object" "auth_fn_arn" {
  bucket = "${var.config_bucket}"
  key = "${var.authorizer_name}/arn"
}

data "aws_s3_bucket_object" "auth_fn_invoke_arn" {
  bucket = "${var.config_bucket}"
  key = "${var.authorizer_name}/invoke_arn"
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "${data.aws_s3_bucket_object.auth_fn_name.body}"
  rest_api_id            = "${aws_api_gateway_rest_api.protectedresource.id}"
  authorizer_uri         = "${data.aws_s3_bucket_object.auth_fn_invoke_arn.body}"
  authorizer_result_ttl_in_seconds = "0"
}

resource "aws_iam_role" "authorizer_invocation_role" {
  name = "api_gateway_${var.resource_name}_invocation"
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

resource "aws_iam_role_policy" "authorizer_invocation_policy" {
  name = "${var.resource_name}_invocation_policy"
  role = "${aws_iam_role.authorizer_invocation_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${data.aws_s3_bucket_object.auth_fn_arn.body}"
    }
  ]
}
EOF
}

