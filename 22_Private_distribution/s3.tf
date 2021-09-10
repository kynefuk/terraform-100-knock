resource "random_string" "bucket_prefix" {
  length  = 16
  lower   = true
  upper   = false
  special = false
}

resource "aws_s3_bucket" "origin" {
  bucket = random_string.bucket_prefix.result
  acl    = "private"

  force_destroy = true

  tags = {
    "Name" = "${var.project}_origin"
  }
}

# resource "aws_s3_bucket_policy" "public" {
#   bucket = aws_s3_bucket.origin.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Id      = "MYBUCKETPOLICY"
#     Statement = [
#       {
#         Sid       = "Public"
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = "s3:GetObject"
#         Resource = [
#           "${aws_s3_bucket.origin.arn}/*",
#         ]
#       },
#     ]
#   })
# }

resource "aws_s3_bucket_object" "index" {
  bucket        = aws_s3_bucket.origin.id
  key           = "index.html"
  source        = "html/index.html"
  content_type  = "text/html"
  acl           = "private"
  force_destroy = true
}

