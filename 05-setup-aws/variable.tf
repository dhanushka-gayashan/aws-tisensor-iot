variable "region" {
  type = string
  default = "us-east-1"
  description = "AWS Region"
}

variable "hosted_zone_domain" {
  type = string
  default = "dhanuzone.com"
  description = "Route 53 Hosted Zone domain"
}