# create a new REST API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.api_name}"
}

module "http_resources" {
  source = "../http-resources"

  aws_region = "${var.region}"

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"

  rest_api_root_resource_id = "${aws_api_gateway_rest_api.api.root_resource_id}"

  validator_id = "${aws_api_gateway_authorizer.validator.id}"

  names = "${var.names}"

  paths = "${var.paths}"

  methods = "${var.methods}"

  validations = "${var.validations}"

  lambda_arns = "${aws_lambda_function.lambdas.*.arn}"
}

# deploy the REST API to the prod stage (for now)
resource "aws_api_gateway_deployment" "api_stage_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "prod"
  depends_on  = ["module.http_resources"]
}
