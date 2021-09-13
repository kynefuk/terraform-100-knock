resource "aws_cloudfront_origin_access_identity" "oci" {
  comment = "oci to s3 origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.origin.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oci.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "error.html"
  price_class         = "PriceClass_200"
  aliases             = [local.sub_domain]

  custom_error_response {
    error_caching_min_ttl = 30
    error_code            = 403
    response_code         = 502
    response_page_path    = "/error.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.for_cloudfront.arn
    ssl_support_method             = "sni-only"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.origin.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 300
    compress               = true
  }

  depends_on = [
    aws_acm_certificate.for_cloudfront
  ]

  tags = {
    "Name" = "${var.project}_s3_distribution"
  }
}
