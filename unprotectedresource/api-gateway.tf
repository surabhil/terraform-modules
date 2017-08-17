# create a new REST API Gateway
resource "aws_api_gateway_rest_api" "unprotectedresource" {
  name = "${var.resource_name}"
}

module "http_method" {
  source = "../httpresource"

  aws_region = "${var.aws_region}"

  rest_api_id = "${aws_api_gateway_rest_api.unprotectedresource.id}"

  rest_api_root_resource_id = "${aws_api_gateway_rest_api.unprotectedresource.root_resource_id}"

  resource_lambda_arn = "${aws_lambda_function.unprotectedresource.arn}"

  resource_path = "${var.resource_path}"

  resource_method = "${var.resource_method}"

  resource_parent_id = "${var.resource_parent_id}"

  request_parameters = "${var.request_parameters}"
}

#  allow API Gateway to execute the Lambda function
resource "aws_lambda_permission" "unprotectedresource_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.unprotectedresource.arn}"
  principal     = "apigateway.amazonaws.com"
}

# deploy the REST API to the prod stage (for now)
resource "aws_api_gateway_deployment" "unprotectedresource_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.unprotectedresource.id}"
  stage_name  = "prod"
  depends_on  = ["module.http_method"]
}

# write the endpoint's invoke URL to S3, so it can be used by other APIs in the future
resource "aws_s3_bucket_object" "unprotectedresource_endpoint_invoke_url" {
  bucket       = "${var.config_bucket}"
  key          = "lambdas/${var.resource_name}/endpoint_invoke_url"
  content      = "${aws_api_gateway_deployment.unprotectedresource_prod.invoke_url}"
  content_type = "text/plain"
}
