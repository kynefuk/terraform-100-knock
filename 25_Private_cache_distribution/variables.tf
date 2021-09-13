variable "project" {
  default = "25_Private_cache_distribution"
}

variable "az" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}
