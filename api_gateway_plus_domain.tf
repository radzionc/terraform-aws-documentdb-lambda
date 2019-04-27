resource "aws_api_gateway_domain_name" "service" {
  count = "${var.main_domain != "" ? 1 : 0}"
  certificate_arn = "${var.certificate_arn}"
  domain_name     = "${var.name}.${var.main_domain}"
}

resource "aws_route53_record" "service" {
  count = "${var.main_domain != "" ? 1 : 0}"
  name    = "${aws_api_gateway_domain_name.service.domain_name}"
  type    = "A"
  zone_id = "${var.zone_id}"

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.service.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.service.cloudfront_zone_id}"
  }
}

resource "aws_api_gateway_base_path_mapping" "service" {
  count = "${var.main_domain != "" ? 1 : 0}"
  api_id      = "${aws_api_gateway_rest_api.service.id}"
  stage_name  = "${aws_api_gateway_deployment.service.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.service.domain_name}"
}