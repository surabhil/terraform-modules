data "aws_route53_zone" "apimarket-zone" {
  name = "${var.domain}."
}

data "aws_acm_certificate" "test-cert" {
  provider = "aws.use1"
  domain = "${var.subdomain}.${var.domain}"
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "test-domain" {
  domain_name = "${var.subdomain}.${var.domain}"
  certificate_arn = "${data.aws_acm_certificate.test-cert.arn}"
}

resource "aws_route53_record" "test-record" {
  zone_id = "${data.aws_route53_zone.apimarket-zone.zone_id}"

  name = "${aws_api_gateway_domain_name.test-domain.domain_name}"
  type = "A"

  alias {
    name = "${aws_api_gateway_domain_name.test-domain.cloudfront_domain_name}"
    zone_id = "${aws_api_gateway_domain_name.test-domain.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_api_gateway_base_path_mapping" "test-mapping" {
  api_id = "${var.api_id}"
  stage_name = "${var.api_stage}"
  domain_name = "${aws_api_gateway_domain_name.test-domain.domain_name}"
  base_path = "${var.resource_name}"
}
