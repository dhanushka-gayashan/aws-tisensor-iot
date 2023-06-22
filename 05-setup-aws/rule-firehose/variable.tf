variable "enable" {
  type = bool
  default = false
  description = "enable or disable the rule"
}

variable "hosted_zone_id" {
  type = string
  default = ""
  description = "dns hosted zone id"
}

variable "api_gateway_domain" {
  type = string
  default = "api.iot.dhanuzone.com"
  description = "api gateway domain"
}