# also output the invoke url (for use in chaining modules together if desired)
output "endpoint_invoke_url" {
  value = "${aws_api_gateway_deployment.protectedresource_prod.invoke_url}"
}

# ID of the REST API (for creating a custom domain)
output "api_id" {
  value = "${aws_api_gateway_rest_api.protectedresource.id}"
}

# stage of the REST API (for creating a custom domain)
output "api_stage" {
  value = "${aws_api_gateway_deployment.protectedresource_prod.stage_name}"
}
