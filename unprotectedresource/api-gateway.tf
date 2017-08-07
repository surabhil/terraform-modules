# create a new REST API Gateway
resource "aws_api_gateway_rest_api" "unprotectedresource" {
  name = "${var.resource_name}"
}

# create a new method that responds to ANY HTTP method at the root of the REST API
resource "aws_api_gateway_method" "unprotectedresourceany" {
  rest_api_id   = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  resource_id   = "${aws_api_gateway_rest_api.unprotectedresource.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

# add a Lambda integration, using the Lambda created in lamdba.tf
resource "aws_api_gateway_integration" "unprotectedresource_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  resource_id             = "${aws_api_gateway_rest_api.unprotectedresource.root_resource_id}"
  http_method             = "${aws_api_gateway_method.unprotectedresourceany.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.unprotectedresource.arn}/invocations"
}

# create the corresponding response and integration response (if someone could explain this to me that would be great)
resource "aws_api_gateway_method_response" "unprotectedresource_200response" {
  depends_on  = ["aws_api_gateway_integration.unprotectedresource_integration"]
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

# deploy the REST API to the prod stage (for now)
resource "aws_api_gateway_deployment" "unprotectedresource_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  stage_name  = "prod"
  depends_on  = ["aws_api_gateway_method.unprotectedresourceany", "aws_api_gateway_integration.unprotectedresource_integration"]
}

# write the endpoint's invoke URL to S3, so it can be used by other APIs in the future
resource "aws_s3_bucket_object" "githubsignin_endpoint_invoke_url" {
  bucket       = "${var.config_bucket}"
  key          = "lambdas/${var.resource_name}/endpoint_invoke_url"
  content      = "${aws_api_gateway_deployment.unprotectedresource_prod.invoke_url}"
  content_type = "text/plain"
}
