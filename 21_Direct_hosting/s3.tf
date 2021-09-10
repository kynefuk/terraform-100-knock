resource "random_string" "bucket_prefix" {
  length  = 16
  lower   = true
  upper   = false
  special = false
}

resource "aws_s3_bucket" "origin" {
  bucket = random_string.bucket_prefix.result
  acl    = "public-read"
  website {
    index_document = "index.html"
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
        Sid       = "Public"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.origin.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_object" "index" {
  bucket        = aws_s3_bucket.origin.id
  key           = "index.html"
  source        = "html/index.html"
  content_type  = "text/html"
  acl           = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket_object" "error" {
  bucket        = aws_s3_bucket.origin.id
  key           = "error.html"
  source        = "html/error.html"
  content_type  = "text/html"
  acl           = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket_object" "hoge" {
  bucket        = aws_s3_bucket.origin.id
  key           = "hoge.html"
  source        = "html/hoge.html"
  content_type  = "text/html"
  acl           = "public-read"
  force_destroy = true
}
