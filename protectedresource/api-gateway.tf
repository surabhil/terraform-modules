# create a new REST API Gateway
resource "aws_api_gateway_rest_api" "protectedresource" {
  name = "${var.resource_name}"
}

# create a new method that responds to ANY HTTP method at the root of the REST API
# add a custom authorization, using the authorizer created in custom-authorizer.tf
resource "aws_api_gateway_method" "protectedresourceany" {
  rest_api_id   = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id   = "${aws_api_gateway_rest_api.protectedresource.root_resource_id}"
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.authorizer.id}"
}

# add a Lambda integration, using the Lambda created below
resource "aws_api_gateway_integration" "protectedresource_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.protectedresource.id}"
  resource_id             = "${aws_api_gateway_rest_api.protectedresource.root_resource_id}"
  http_method             = "${aws_api_gateway_method.protectedresourceany.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.protectedresource.arn}/invocations"
}

# create the corresponding response and integration response (if someone could explain this to me that would be great)
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

# deploy the REST API to the prod stage (for now)
resource "aws_api_gateway_deployment" "protectedresource_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  stage_name  = "prod"
  depends_on = ["aws_api_gateway_method.protectedresourceany", "aws_api_gateway_integration.protectedresource_integration"]
}

# write the endpoint's invoke URL to S3, so it can be used by other APIs in the future
resource "aws_s3_bucket_object" "endpoint_invoke_url" {
  bucket = "${var.config_bucket}"
  key = "lambdas/${var.resource_name}/endpoint_invoke_url"
  content = "${aws_api_gateway_deployment.protectedresource_prod.invoke_url}"
  content_type = "text/plain"
}
