resource "aws_api_gateway_account" "apigatewayaccount" {
  cloudwatch_role_arn = "${aws_iam_role.apigateway_cloudwatch_global_role.arn}"
}

resource "aws_iam_role" "apigateway_cloudwatch_global_role" {
  name = "apigateway_cloudwatch_global_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "apigateway_cloudwatch_global_role_policy" {
  name = "apigateway_cloudwatch_global_role_policy"
  role = "${aws_iam_role.apigateway_cloudwatch_global_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
