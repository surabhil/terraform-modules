# create a new REST API Gateway
resource "aws_api_gateway_rest_api" "protectedresource" {
  name = "${var.api_name}"
}

module "http_method" {
  count = "${length(var.resources)}"

  source = "../httpresource"

  aws_region = "${var.aws_region}"

  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"

  rest_api_root_resource_id = "${aws_api_gateway_rest_api.protectedresource.root_resource_id}"

  authorizer_id = "${aws_api_gateway_authorizer.authorizer.id}"

  resource_lambda_arn = "${element(aws_lambda_function.protectedresources.arn, count.index)}"

  resource_path = "${element(var.resources, count.index).path}"

  resource_method = "${element(var.resources, count.index).method}"

  resource_parent_id = "${element(var.resources, count.index).parent_id}"
}

#  allow API Gateway to execute the Lambda functions
resource "aws_lambda_permission" "protectedresource_apigw_lambda_permission" {
  count = "${length(var.resources)}"

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${element(aws_lambda_function.protectedresources.arn, count.index)}"
  principal     = "apigateway.amazonaws.com"
}

# deploy the REST API to the prod stage (for now)
resource "aws_api_gateway_deployment" "protectedresource_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  stage_name  = "prod"
  depends_on  = ["module.http_method"]
}

# write the endpoint's invoke URL to S3, so it can be used by other APIs in the future
resource "aws_s3_bucket_object" "protectedresource_endpoint_invoke_url" {
  bucket       = "${var.config_bucket}"
  key          = "lambdas/${var.api_name}/endpoint_invoke_url"
  content      = "${aws_api_gateway_deployment.protectedresource_prod.invoke_url}"
  content_type = "text/plain"
}
