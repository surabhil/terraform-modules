data "aws_route53_zone" "apimarket-zone" {
  name = "${var.domain}."
}

data "aws_acm_certificate" "api_gateway_domain_cert" {
  provider = "aws.use1"
  domain = "${var.subdomain}.${var.domain}"
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "api_gateway_domain" {
  domain_name = "${var.subdomain}.${var.domain}"
  certificate_arn = "${data.aws_acm_certificate.api_gateway_domain_cert.arn}"
}

resource "aws_route53_record" "cloudwatch_record" {
  zone_id = "${data.aws_route53_zone.apimarket-zone.zone_id}"

  name = "${aws_api_gateway_domain_name.api_gateway_domain.domain_name}"
  type = "A"

  alias {
    name = "${aws_api_gateway_domain_name.api_gateway_domain.cloudfront_domain_name}"
    zone_id = "${aws_api_gateway_domain_name.api_gateway_domain.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}
