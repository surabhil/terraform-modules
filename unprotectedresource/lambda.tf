# zip up the provided Javascript code to deploy to Lambda
data "archive_file" "resource_zip" {
  type        = "zip"
  source_file = "${var.resource_name}.js"
  output_path = "${var.resource_name}.js.zip"
}

# create a new Lambda function from the zipped file created above
resource "aws_lambda_function" "unprotectedresource" {
  filename         = "${var.resource_name}.js.zip"
  function_name    = "${var.resource_name}"
  role             = "${aws_iam_role.unprotectedresource_lambdarole.arn}"
  handler          = "${var.resource_name}.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file(data.archive_file.resource_zip.output_path))}"

  environment {
    variables = "${var.environment_variables}"
  }
}

# IAM role & policy for the Lambda function (allow it to write to CloudWatch)
resource "aws_iam_role" "unprotectedresource_lambdarole" {
  name = "${var.resource_name}_lambdarole"

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

resource "aws_iam_role_policy" "unprotectedresource_lambdarole_policy" {
  name = "${var.resource_name}_lambdarole_policy"
  role = "${aws_iam_role.unprotectedresource_lambdarole.id}"

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

#  allow API Gateway to execute the Lambda function
resource "aws_lambda_permission" "unprotectedresource_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.unprotectedresource.arn}"
  principal     = "apigateway.amazonaws.com"
}
