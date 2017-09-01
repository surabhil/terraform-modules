# zip up the provided Javascript code to deploy to Lambda
data "archive_file" "validator_zip" {
  type        = "zip"
  source_file = "${path.module}/${var.validator_filename}.js"
  output_path = "${path.module}/${var.validator_filename}.js.zip"
}

# create a new Lambda function from the zipped file created above
resource "aws_lambda_function" "validator_lambda" {
  filename         = "${data.archive_file.validator_zip.output_path}"
  function_name    = "${var.validator_name}"
  role             = "${aws_iam_role.validator_lambda_role.arn}"
  handler          = "${var.validator_filename}.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file(data.archive_file.validator_zip.output_path))}"

  environment {
    variables = "${var.validator_environment_variables}"
  }
}

#  allow API Gateway to execute the Lambda function
resource "aws_lambda_permission" "validator_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.validator_lambda.arn}"
  principal     = "apigateway.amazonaws.com"
}

# IAM role & policy for the Lambda function (allow it to write to CloudWatch)
resource "aws_iam_role" "validator_lambda_role" {
  name = "${var.validator_name}_lambdarole"

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

resource "aws_iam_role_policy" "validator_lambda_role_policy" {
  name = "${var.validator_name}_lambdarole_policy"
  role = "${aws_iam_role.validator_lambda_role.id}"

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
