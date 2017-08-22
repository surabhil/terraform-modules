# zip up the provided Javascript code to deploy to Lambda
data "archive_file" "resource_zips" {
  count = "${length(var.names)}"

  type        = "zip"
  source_file = "${element(var.names, count.index)}.js"
  output_path = "${element(var.names, count.index)}.js.zip"
}

# create a new Lambda function from the zipped file created above
resource "aws_lambda_function" "protectedresources" {
  count = "${length(var.names)}"

  filename         = "${element(var.names, count.index)}.js.zip"
  function_name    = "${element(var.names, count.index)}"
  role             = "${element(aws_iam_role.protectedresource_lambdaroles.*.arn, count.index)}"
  handler          = "${element(var.names, count.index)}.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file(element(data.archive_file.resource_zips.*.output_path, count.index)))}"

  environment {
    variables = "${var.environment_variables}"
  }
}

#  allow API Gateway to execute the Lambda functions
resource "aws_lambda_permission" "protectedresource_apigw_lambda_permissions" {
  count = "${length(var.names)}"

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${element(aws_lambda_function.protectedresources.*.arn, count.index)}"
  principal     = "apigateway.amazonaws.com"
}

# IAM role & policy for the Lambda function (allow it to write to CloudWatch)
resource "aws_iam_role" "protectedresource_lambdaroles" {
  count = "${length(var.names)}"

  name = "${element(var.names, count.index)}_lambdarole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "protectedresource_lambdarole_policies" {
  count = "${length(var.names)}"

  name = "${element(var.names, count.index)}_lambdarole_policy"
  role = "${element(aws_iam_role.protectedresource_lambdaroles.*.id, count.index)}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
