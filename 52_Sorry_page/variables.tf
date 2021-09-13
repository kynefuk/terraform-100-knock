variable "project" {
  default = "52_Sorry_page"
}

variable "az" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "domain" {
  type = string
}
