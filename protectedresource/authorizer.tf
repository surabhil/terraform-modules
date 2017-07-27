resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "${var.authorizer_name}"
  rest_api_id            = "${aws_api_gateway_rest_api.protectedresource.id}"
  authorizer_uri         = "${aws_lambda_function.authorizer.invoke_arn}"
  authorizer_result_ttl_in_seconds = "0"
}

resource "aws_iam_role" "authorizer_invocation_role" {
  name = "api_gateway_${var.authorizer_name}_invocation"
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
  name = "${var.authorizer_name}_invocation_policy"
  role = "${aws_iam_role.authorizer_invocation_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.authorizer.arn}"
    }
  ]
}
EOF
}

# Lambda
resource "aws_lambda_permission" "authorizer_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.authorizer.arn}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_function" "authorizer" {
  filename         = "${var.authorizer_name}.js.zip"
  function_name    = "${var.authorizer_name}"
  role             = "${aws_iam_role.authorizer_lambdarole.arn}"
  handler          = "${var.authorizer_name}.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file("${var.authorizer_name}.js.zip"))}"
}

# IAM
resource "aws_iam_role" "authorizer_lambdarole" {
  name = "${var.authorizer_name}_lambdarole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authorizer_lambdarole_policy" {
  name = "${var.authorizer_name}_lambdarole_policy"
  role = "${aws_iam_role.authorizer_lambdarole.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
