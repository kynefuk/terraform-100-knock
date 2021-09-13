resource "aws_acm_certificate" "for_cloudfront" {
  provider          = aws.us_east_1
  domain_name       = local.sub_domain
  validation_method = "DNS"

  tags = {
    "Name" = "${var.project}_acm_for_cloudfront"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "for_cloudfront" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.for_cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_validation : record.fqdn]
  depends_on = [
    aws_route53_record.hoge_a_primary_record,
    aws_route53_record.hoge_ns_record
  ]
}

resource "aws_acm_certificate" "for_alb" {
  domain_name       = local.sub_domain
  validation_method = "DNS"

  tags = {
    "Name" = "${var.project}_acm_for_alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "for_alb" {
  certificate_arn         = aws_acm_certificate.for_alb.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_validation : record.fqdn]
  depends_on = [
    aws_route53_record.hoge_a_primary_record,
    aws_route53_record.hoge_ns_record
  ]
}
