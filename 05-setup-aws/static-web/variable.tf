variable "hosted_zone_id" {
  type = string
  default = ""
  description = "dns hosted zone id"
}

variable "s3_web_domain" {
  type = string
  default = "iot.dhanuzone.com"
  description = "s3 web domain"
}