output "endpoint_invoke_url" {
  value = "${aws_api_gateway_deployment.unprotectedresource_prod.invoke_url}"
}

output "api_id" {
  value = "${aws_api_gateway_rest_api.unprotectedresource.id}"
}

output "api_stage" {
  value = "${aws_api_gateway_deployment.unprotectedresource_prod.stage_name}"
}