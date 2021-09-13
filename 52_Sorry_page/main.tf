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
      "Project" = "52_Sorry_page"
    }
  }
}


provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
