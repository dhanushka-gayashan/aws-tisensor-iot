variable "enable" {
  type = bool
  default = false
  description = "enable or disable the rule"
}

variable "region" {
  type = string
  default = "us-east-1"
  description = "AWS Region"
}