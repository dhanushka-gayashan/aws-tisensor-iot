# route53
data "aws_route53_zone" "main" {
  name         = var.hosted_zone_domain
  private_zone = false
}

# iot-core mqtt broker
module "iot-core" {
  source = "./iot-core"
}

# iot-core: dynamodb rule
module "rule-dynamodb" {
  source = "./rule-dynamodb"
  enable = false
}

# iot-core: firehose rule
module "rule-firehose" {
  source = "./rule-firehose"
  enable = false
  region = var.region
  hosted_zone_id = data.aws_route53_zone.main.zone_id
}

# iot-core: timestream rule
module "rule-timestream" {
  source = "./rule-timestreamdb"
  enable = true
}

