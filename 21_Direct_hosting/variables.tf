variable "project" {
  default = "21_Direct_hosting"
}

variable "az" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}
