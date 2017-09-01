# output authorizer Lambda arn & invoke arn , for use in protected resources
output "validator_arn" {
  value = "${aws_lambda_function.validator_lambda.arn}"
}

output "validator_invoke_arn" {
  value = "${aws_lambda_function.validator_lambda.invoke_arn}"
}
