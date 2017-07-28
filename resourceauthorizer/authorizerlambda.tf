# Lambda
resource "aws_lambda_permission" "authorizer_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.authorizer.arn}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_function" "authorizer" {
  filename         = "authorizer.js.zip"
  function_name    = "authorizer"
  role             = "${aws_iam_role.authorizer_lambdarole.arn}"
  handler          = "authorizer.handler"
  runtime          = "nodejs6.10"
  source_code_hash = "${base64sha256(file("authorizer.js.zip"))}"
}

# IAM
resource "aws_iam_role" "authorizer_lambdarole" {
  name = "authorizer_lambdarole"

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
  name = "authorizer_lambdarole_policy"
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
