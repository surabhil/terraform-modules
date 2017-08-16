# create a new REST API Gateway
resource "aws_api_gateway_rest_api" "protectedresource" {
  name = "${var.api_name}"
}

resource "aws_api_gateway_resource" "rest_resources" {
  count = "${length(var.names)}"

  parent_id = "${element(var.parent_ids, count.index) == "" ? aws_api_gateway_rest_api.protectedresource.root_resource_id : element(var.parent_ids, count.index)}"
  path_part = "${element(var.paths, count.index)}"
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
}

resource "aws_api_gateway_method" "http_methods" {
  count = "${length(var.names)}"

  rest_api_id   = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id   = "${element(aws_api_gateway_resource.rest_resources.id, count.index)}"
  http_method   = "${element(var.names, count.index) == "" ? "ANY" : element(var.names, count.index)}"
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.authorizer.id}"
}

# add a Lambda integration, using the Lambda created in lambdas.tf
resource "aws_api_gateway_integration" "protectedresource_integrations" {
  count = "${length(var.names)}"

  rest_api_id             = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id             = "${element(aws_api_gateway_resource.rest_resources.id, count.index)}"
  http_method             = "${element(aws_api_gateway_method.http_methods.http_method, count.index)}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${element(aws_lambda_function.protectedresources.arn, count.index)}/invocations"
}

# create the corresponding response and integration response (if someone could explain this to me that would be great)
resource "aws_api_gateway_method_response" "protectedresource_responses" {
  count = "${length(var.names)}"

  depends_on  = ["aws_api_gateway_integration.protectedresource_integrations"]
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id = "${element(aws_api_gateway_method.http_methods.resource_id, count.index)}"
  http_method = "${element(aws_api_gateway_method.http_methods.http_method, count.index)}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "protectedresource_integrationresponses" {
  count = "${length(var.names)}"

  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id = "${element(aws_api_gateway_method.http_methods.resource_id, count.index)}"
  http_method = "${element(aws_api_gateway_method.http_methods.http_method, count.index)}"
  status_code = "${element(aws_api_gateway_method_response.protectedresource_responses.status_code, count.index)}"
}

#  allow API Gateway to execute the Lambda functions
resource "aws_lambda_permission" "protectedresource_apigw_lambda_permission" {
  count = "${length(var.names)}"

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${element(aws_lambda_function.protectedresources.arn, count.index)}"
  principal     = "apigateway.amazonaws.com"
}

# deploy the REST API to the prod stage (for now)
resource "aws_api_gateway_deployment" "protectedresource_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  stage_name  = "prod"
  depends_on  = ["aws_api_gateway_method.http_methods", "aws_api_gateway_integration.protectedresource_integrations"]
}

# write the endpoint's invoke URL to S3, so it can be used by other APIs in the future
resource "aws_s3_bucket_object" "protectedresource_endpoint_invoke_url" {
  bucket       = "${var.config_bucket}"
  key          = "lambdas/${var.api_name}/endpoint_invoke_url"
  content      = "${aws_api_gateway_deployment.protectedresource_prod.invoke_url}"
  content_type = "text/plain"
}
