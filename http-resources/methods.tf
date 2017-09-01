resource "aws_api_gateway_resource" "http_resources" {
  count = "${length(var.names)}"

  parent_id = "${element(var.parent_ids, 0) == "" ? var.rest_api_root_resource_id : element(var.parent_ids, count.index)}"
  path_part = "${element(var.paths, count.index)}"
  rest_api_id = "${var.rest_api_id}"
}

resource "aws_api_gateway_method" "http_methods" {
  count = "${length(var.names)}"

  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${element(aws_api_gateway_resource.http_resources.*.id, count.index)}"
  http_method   = "${element(var.methods, count.index) == "" ? "ANY" : element(var.methods, count.index)}"
  authorization = "${element(var.validations, count.index)}"
  authorizer_id = "${element(var.validations, count.index) == "CUSTOM" ? var.validator_id : ""}"
}

# add Lambda integrations, using the Lambdas created in lambdas.tf
resource "aws_api_gateway_integration" "http_integrations" {
  count = "${length(var.names)}"

  rest_api_id             = "${var.rest_api_id}"
  resource_id             = "${element(aws_api_gateway_resource.http_resources.*.id, count.index)}"
  http_method             = "${element(aws_api_gateway_method.http_methods.*.http_method, count.index)}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${element(var.lambda_arns, count.index)}/invocations"
}

# create the corresponding response and integration responses (if someone could explain this to me that would be great)
resource "aws_api_gateway_method_response" "http_responses" {
  count = "${length(var.names)}"

  depends_on  = ["aws_api_gateway_integration.http_integrations"]
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${element(aws_api_gateway_method.http_methods.*.resource_id, count.index)}"
  http_method = "${element(aws_api_gateway_method.http_methods.*.http_method, count.index)}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "http_integration_responses" {
  count = "${length(var.names)}"

  rest_api_id = "${var.rest_api_id}"
  resource_id = "${element(aws_api_gateway_method.http_methods.*.resource_id, count.index)}"
  http_method = "${element(aws_api_gateway_method.http_methods.*.http_method, count.index)}"
  status_code = "${element(aws_api_gateway_method_response.http_responses.*.status_code, count.index)}"
}
