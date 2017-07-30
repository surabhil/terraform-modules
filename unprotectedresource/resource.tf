# API Gateway
resource "aws_api_gateway_rest_api" "unprotectedresource" {
  name = "${var.resource_name}"
}

resource "aws_api_gateway_method" "unprotectedresourceany" {
  rest_api_id   = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  resource_id   = "${aws_api_gateway_rest_api.unprotectedresource.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "unprotectedresource_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  resource_id             = "${aws_api_gateway_rest_api.unprotectedresource.root_resource_id}"
  http_method             = "${aws_api_gateway_method.unprotectedresourceany.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-west-1:lambda:path/2015-03-31/functions/${aws_lambda_function.unprotectedresource.arn}/invocations"
}

resource "aws_api_gateway_method_response" "unprotectedresource_200response" {
  depends_on = ["aws_api_gateway_integration.unprotectedresource_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  resource_id = "${aws_api_gateway_method.unprotectedresourceany.resource_id}"
  http_method = "${aws_api_gateway_method.unprotectedresourceany.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "unprotectedresource_integrationresponse" {
  rest_api_id = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  resource_id = "${aws_api_gateway_method.unprotectedresourceany.resource_id}"
  http_method = "${aws_api_gateway_method.unprotectedresourceany.http_method}"
  status_code = "${aws_api_gateway_method_response.unprotectedresource_200response.status_code}"
}

resource "aws_api_gateway_deployment" "unprotectedresource_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  stage_name  = "prod"
  depends_on = ["aws_api_gateway_method.unprotectedresourceany", "aws_api_gateway_integration.unprotectedresource_integration"]
}

# Lambda
resource "aws_lambda_permission" "unprotectedresource_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.unprotectedresource.arn}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_function" "unprotectedresource" {
  filename         = "${var.resource_name}.js.zip"
  function_name    = "${var.resource_name}"
  role             = "${aws_iam_role.unprotectedresource_lambdarole.arn}"
  handler          = "${var.resource_name}.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file("${var.resource_name}.js.zip"))}"
}

# IAM
resource "aws_iam_role" "unprotectedresource_lambdarole" {
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

resource "aws_iam_role_policy" "unprotectedresource_lambdarole_policy" {
  name = "${var.resource_name}_lambdarole_policy"
  role = "${aws_iam_role.unprotectedresource_lambdarole.id}"

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
