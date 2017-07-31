output "endpoint_invoke_url" {
  value = "${aws_api_gateway_deployment.protectedresource_prod.invoke_url}"
}