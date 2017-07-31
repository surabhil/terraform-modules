output "endpoint_invoke_url" {
  value = "${aws_api_gateway_deployment.unprotectedresource_prod.invoke_url}"
}
