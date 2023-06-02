resource "aws_dynamodb_table" "iot_inject_dynamodb" {
  name           = "IotTopicRuleInjectTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "timestamp"
  range_key      = "type"

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "type"
    type = "S"
  }
}