# create a new REST API Gateway
resource "aws_api_gateway_rest_api" "protectedresource" {
  name = "${var.api_name}"
}

module "http_resources" {
  source = "../httpresources"

  aws_region = "${var.aws_region}"

  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"

  rest_api_root_resource_id = "${aws_api_gateway_rest_api.protectedresource.root_resource_id}"

  authorizer_id = "${aws_api_gateway_authorizer.authorizer.id}"

  names = "${var.names}"

  paths = "${var.paths}"

  methods = "${var.methods}"

  parent_ids = "${var.parent_ids}"

  authorization = "${var.authorization}"

  lambda_arns = "${aws_lambda_function.protectedresources.*.arn}"
}

# deploy the REST API to the prod stage (for now)
resource "aws_api_gateway_deployment" "protectedresource_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.protectedresource.id}"
  stage_name  = "prod"
  depends_on  = ["module.http_resourcers"]
}

# write the endpoint's invoke URL to S3, so it can be used by other APIs in the future
resource "aws_s3_bucket_object" "protectedresource_endpoint_invoke_url" {
  bucket       = "${var.config_bucket}"
  key          = "lambdas/${var.api_name}/endpoint_invoke_url"
  content      = "${aws_api_gateway_deployment.protectedresource_prod.invoke_url}"
  content_type = "text/plain"
}
