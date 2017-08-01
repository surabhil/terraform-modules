output "endpoint_invoke_url" {
  value = "${aws_api_gateway_deployment.protectedresource_prod.invoke_url}"
}

output "api_id" {
  value = "${aws_api_gateway_rest_api.protectedresource.id}"
}

output "api_stage" {
  value = "${aws_api_gateway_deployment.protectedresource_prod.stage_name}"
}