# route53
data "aws_route53_zone" "main" {
  name         = var.hosted_zone_domain
  private_zone = false
}

# iot-core mqtt broker
module "iot-core" {
  source = "./iot-core"
}

# WORKING - DEVICE: iot-core rule : dynamodb rule
module "rule-dynamodb" {
  source = "./rule-dynamodb"
  enable = false
}

# WORKING - DEVICE: iot-core rule : timestream rule
module "rule-timestream" {
  source = "./rule-timestreamdb"
  enable = true
}

# WORKING - DEVICE: iot-core rule : firehose rule
module "rule-firehose" {
  source         = "./rule-firehose"
  region         = var.region
  hosted_zone_id = data.aws_route53_zone.main.zone_id
  enable         = false
}

# WORKING - DEVICE: iot-core rule : kinesis
module "rule-kinesis" {
  source         = "./rule-kinesis"
  region         = var.region
  hosted_zone_id = data.aws_route53_zone.main.zone_id
  enable         = false
}

# TODO: Find how to acquire ws connection id for publish lambda
#module "rule-lambda" {
#  source = "./rule-lambda"
#  region = var.region
#  hosted_zone_id = data.aws_route53_zone.main.zone_id
#  enable = false
#}

# static web
module "static-web" {
  source         = "./static-web"
  hosted_zone_id = data.aws_route53_zone.main.zone_id
}


