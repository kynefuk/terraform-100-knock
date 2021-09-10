terraform {
  required_version = "~> 1.0.5"
  required_providers {
    aws = {
      version = "~> 3.57.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      "Project" = "22_Private_distribution"
    }
  }
}

output "iam_access_key" {
  value = aws_iam_access_key.for_presign.id
}

output "iam_secret_key" {
  value     = nonsensitive(aws_iam_access_key.for_presign.secret)
  sensitive = false
}
