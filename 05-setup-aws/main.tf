# route53
data "aws_route53_zone" "main" {
  name         = var.hosted_zone_domain
  private_zone = false
}

# iot-core mqtt broker
module "iot-core" {
  source = "./iot-core"
}

# iot-core rule : dynamodb rule
module "rule-dynamodb" {
  source = "./rule-dynamodb"
  enable = false
}

# TODO: iot-core rule : timestream rule -> CREATE GRAFANA DASHBOARD
module "rule-timestream" {
  source = "./rule-timestreamdb"
  enable = false
}

# iot-core rule : firehose rule
module "rule-firehose" {
  source = "./rule-firehose"
  region = var.region
  hosted_zone_id = data.aws_route53_zone.main.zone_id
  enable = false
}

module "rule-lambda" {
  source = "./rule-lambda"
  region = var.region
  enable = true
}
