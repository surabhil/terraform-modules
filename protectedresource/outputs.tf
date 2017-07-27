output "${aws_api_gateway_rest_api.protectedresource.name} Lambda Endpoint" {
  value = "${aws_api_gateway_deployment.protectedresource_prod.invoke_url}"
}