resource "aws_api_gateway_resource" "rest_resource" {
  parent_id = "${var.resource_parent_id == "" ? var.rest_api_root_resource_id : var.resource_parent_id}"
  path_part = "${var.resource_path}"
  rest_api_id = "${var.rest_api_id}"
}

resource "aws_api_gateway_method" "http_method" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${aws_api_gateway_resource.rest_resource.id}"
  http_method   = "${var.resource_method == "" ? "ANY" : var.resource_method}"
  authorization = "${var.authorizer_id == "" ? "NONE" : "CUSTOM"}"
  authorizer_id = "${var.authorizer_id}"
}

# add a Lambda integration, using the Lambda created in lambdas.tf
resource "aws_api_gateway_integration" "protectedresource_integration" {
  rest_api_id             = "${var.rest_api_id}"
  resource_id             = "${aws_api_gateway_resource.rest_resource.id}"
  http_method             = "${aws_api_gateway_method.http_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.resource_lambda_arn}/invocations"
}

# create the corresponding response and integration response (if someone could explain this to me that would be great)
resource "aws_api_gateway_method_response" "protectedresource_response" {
  depends_on  = ["aws_api_gateway_integration.protectedresource_integration"]
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_method.http_method.resource_id}"
  http_method = "${aws_api_gateway_method.http_method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "protectedresource_integrationresponse" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_method.http_method.resource_id}"
  http_method = "${aws_api_gateway_method.http_method.http_method}"
  status_code = "${aws_api_gateway_method_response.protectedresource_response.status_code}"
}
