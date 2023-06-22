# route53
data "aws_route53_zone" "main" {
  name         = var.hosted_zone_domain
  private_zone = false
}


module "iot-core" {
  source = "./iot-core"
}

module "rule-dynamodb" {
  source = "./rule-dynamodb"
  enable = false
}

module "rule-firehose" {
  source = "./rule-firehose"
  enable = true
  hosted_zone_id = data.aws_route53_zone.main.zone_id
}