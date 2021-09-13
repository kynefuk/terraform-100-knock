resource "tls_private_key" "for_cloudfront" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

locals {
  key_dir          = ".keys"
  private_key_path = "${local.key_dir}/private.pem"
  public_key_path  = "${local.key_dir}/public.pem"
}

resource "local_file" "private_key" {
  content         = tls_private_key.for_cloudfront.private_key_pem
  filename        = local.private_key_path
  file_permission = "0600"
  depends_on = [
    tls_private_key.for_cloudfront
  ]
}

resource "local_file" "public_key" {
  content  = tls_private_key.for_cloudfront.public_key_pem
  filename = local.public_key_path
  depends_on = [
    tls_private_key.for_cloudfront
  ]
}

resource "aws_cloudfront_public_key" "pbk" {
  name        = "${var.project}_pbk"
  comment     = "public key for cloudfront"
  encoded_key = tls_private_key.for_cloudfront.public_key_pem
  depends_on = [
    local_file.private_key,
  ]
}

resource "aws_cloudfront_key_group" "ckg" {
  name    = "${var.project}_ckg"
  comment = "key group for cloudfront distribution"
  items   = [aws_cloudfront_public_key.pbk.id]
}
