# API Gateway
resource "aws_api_gateway_rest_api" "protectedresource" {
  name = "${var.resource_name}"
}

resource "aws_api_gateway_method" "protectedresourceany" {
  rest_api_id   = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id   = "${aws_api_gateway_rest_api.protectedresource.root_resource_id}"
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.authorizer.id}"
}

resource "aws_api_gateway_integration" "protectedresource_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id             = "${aws_api_gateway_rest_api.protectedresource.root_resource_id}"
  http_method             = "${aws_api_gateway_method.protectedresourceany.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.protectedresource.arn}/invocations"
}

resource "aws_api_gateway_method_response" "protectedresource_200response" {
  depends_on = ["aws_api_gateway_integration.protectedresource_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id = "${aws_api_gateway_method.protectedresourceany.resource_id}"
  http_method = "${aws_api_gateway_method.protectedresourceany.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "protectedresource_integrationresponse" {
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id = "${aws_api_gateway_method.protectedresourceany.resource_id}"
  http_method = "${aws_api_gateway_method.protectedresourceany.http_method}"
  status_code = "${aws_api_gateway_method_response.protectedresource_200response.status_code}"
}

resource "aws_api_gateway_deployment" "protectedresource_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  stage_name  = "prod"
  depends_on = ["aws_api_gateway_method.protectedresourceany", "aws_api_gateway_integration.protectedresource_integration"]
}

# Lambda
resource "aws_lambda_permission" "protectedresource_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.protectedresource.arn}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_function" "protectedresource" {
  filename         = "${var.resource_name}.js.zip"
  function_name    = "${var.resource_name}"
  role             = "${aws_iam_role.protectedresource_lambdarole.arn}"
  handler          = "${var.resource_name}.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file(var.file_name))}"

  environment {
    variables = "${var.environment_variables}"
  }
}

# IAM
resource "aws_iam_role" "protectedresource_lambdarole" {
  name = "${var.resource_name}_lambdarole"

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

resource "aws_iam_role_policy" "protectedresource_lambdarole_policy" {
  name = "${var.resource_name}_lambdarole_policy"
  role = "${aws_iam_role.protectedresource_lambdarole.id}"

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
