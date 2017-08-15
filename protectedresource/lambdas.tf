# zip up the provided Javascript code to deploy to Lambda
data "archive_file" "resource_zips" {
  count = "${length(var.resources)}"

  type        = "zip"
  source_file = "${element(var.resources, count.index).name}.js"
  output_path = "${element(var.resources, count.index).name}.js.zip"
}

# create a new Lambda function from the zipped file created above
resource "aws_lambda_function" "protectedresources" {
  count = "${length(var.resources)}"

  filename         = "${element(var.resources, count.index).name}.js.zip"
  function_name    = "${element(var.resources, count.index).name}"
  role             = "${element(aws_iam_role.protectedresource_lambdaroles.arn, count.index)}"
  handler          = "${element(var.resources, count.index).name}.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file(element(data.archive_file.resource_zips.output_path, count.index)))}"

  environment {
    variables = "${element(var.resources, count.index).environment_variables}"
  }
}

# IAM role & policy for the Lambda function (allow it to write to CloudWatch)
resource "aws_iam_role" "protectedresource_lambdaroles" {
  count = "${length(var.resources)}"

  name = "${element(var.resources, count.index).name}_lambdarole"

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
  count = "${length(var.resources)}"

  name = "${element(var.resources, count.index).name}_lambdarole_policy"
  role = "${element(aws_iam_role.protectedresource_lambdaroles.id, count.index)}"

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
