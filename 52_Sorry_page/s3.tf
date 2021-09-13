resource "aws_s3_bucket" "origin" {
  bucket = local.sub_domain
  acl    = "private"
  website {
    index_document = "error.html"
    error_document = "error.html"
  }

  force_destroy = true

  tags = {
    "Name" = "${var.project}_origin"
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.origin.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid    = "Public"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oci.iam_arn
        }
        Action = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.origin.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_object" "error" {
  bucket        = aws_s3_bucket.origin.id
  key           = "error.html"
  source        = "html/error.html"
  content_type  = "text/html"
  acl           = "private"
  force_destroy = true
}
