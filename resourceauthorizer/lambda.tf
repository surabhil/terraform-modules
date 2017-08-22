# zip up the provided Javascript code to deploy to Lambda
data "archive_file" "authorizer_zip" {
  type        = "zip"
  source_file = "${var.authorizer_filename}.js"
  output_path = "${var.authorizer_filename}.js.zip"
}

# create a new Lambda function from the zipped file created above
resource "aws_lambda_function" "authorizer" {
  filename         = "${var.authorizer_filename}.js.zip"
  function_name    = "${var.authorizer_name}"
  role             = "${aws_iam_role.authorizer_lambdarole.arn}"
  handler          = "${var.authorizer_filename}.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file(data.archive_file.authorizer_zip.output_path))}"

  environment {
    variables = "${var.environment_variables}"
  }
}

#  allow API Gateway to execute the Lambda function
resource "aws_lambda_permission" "authorizer_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.authorizer.arn}"
  principal     = "apigateway.amazonaws.com"
}

#  allow API Gateway to execute the Lambda function
resource "aws_lambda_permission" "authorizer_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.authorizer.arn}"
  principal     = "apigateway.amazonaws.com"
}

# IAM role & policy for the Lambda function (allow it to write to CloudWatch)
resource "aws_iam_role" "authorizer_lambdarole" {
  name = "${var.authorizer_name}_lambdarole"

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

resource "aws_iam_role_policy" "authorizer_lambdarole_policy" {
  name = "${var.authorizer_name}_lambdarole_policy"
  role = "${aws_iam_role.authorizer_lambdarole.id}"

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
