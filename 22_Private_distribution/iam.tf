resource "aws_iam_user" "for_presign" {
  name = "${var.project}_user_for_presign"
  path = "/"

  tags = {
    "Name" = "${var.project}_user_for_presign"
  }
}

resource "aws_iam_user_policy" "for_presign" {
  name = "${var.project}_policy_for_presign"
  user = aws_iam_user.for_presign.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
        ]
        Resource = "${aws_s3_bucket.origin.arn}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "133.32.224.44/32"
          }
        }
      },
    ]
  })
}

resource "aws_iam_access_key" "for_presign" {
  user = aws_iam_user.for_presign.name
}
