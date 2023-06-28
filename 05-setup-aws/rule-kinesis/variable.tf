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

variable "hosted_zone_id" {
  type = string
  default = ""
  description = "dns hosted zone id"
}

variable "api_gateway_domain" {
  type = string
  default = "ws.iot.dhanuzone.com"
  description = "web socket api gateway domain"
}