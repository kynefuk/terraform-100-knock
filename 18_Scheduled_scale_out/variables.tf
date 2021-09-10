variable "project" {
  default = "18_Scheduled_scale_out"
}

variable "az" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}
