data "aws_route53_zone" "root" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_zone" "hoge" {
  name = local.sub_domain

  tags = {
    "Name" = "${var.project}_hoge"
  }
}

resource "aws_route53_record" "hoge_a_primary_record" {
  zone_id        = aws_route53_zone.hoge.zone_id
  name           = local.sub_domain
  type           = "A"
  set_identifier = "failover_for_primary"
  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "hoge_a_secondary_record" {
  zone_id        = aws_route53_zone.hoge.zone_id
  name           = local.sub_domain
  type           = "A"
  set_identifier = "failover_for_secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "hoge_ns_record" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.sub_domain
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.hoge.name_servers
  depends_on = [
    aws_route53_record.hoge_a_primary_record
  ]
}

resource "aws_route53_record" "dns_validation" {
  for_each = {
    for dvo in aws_acm_certificate.for_cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.hoge.zone_id
  allow_overwrite = true
  depends_on = [
    aws_route53_record.hoge_a_primary_record,
    aws_route53_record.hoge_ns_record
  ]
}
