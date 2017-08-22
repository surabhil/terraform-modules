# output authorizer Lambda arn & invoke arn , for use in protected resources
output "auth_fn_arn" {
  value = "${aws_lambda_function.authorizer.arn}"
}

output "auth_fn_invoke_arn" {
  value = "${aws_lambda_function.authorizer.invoke_arn}"
}
