resource "aws_iot_topic_rule" "iot_topic_rule_dynamodb" {
  name        = "IotTopicRuleDynamodb"
  description = "Iot Topic Rule Dynamodb"
  enabled     = true
  sql         = "SELECT * FROM 'aws/sensorTag'"
  sql_version = "2016-03-23"

  dynamodbv2 {
    put_item {
      table_name = "IotTopicRuleInjectTable"
    }
    role_arn = aws_iam_role.iot_topic_rule_role.arn
  }
}