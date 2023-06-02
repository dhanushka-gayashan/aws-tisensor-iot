resource "aws_iot_topic_rule" "iot_topic_rule_firehose" {
  name        = "IotTopicRuleFirehose"
  description = "Iot Topic Rule Firehose"
  enabled     = true
  sql         = "SELECT * FROM 'aws/sensorTag'"
  sql_version = "2016-03-23"

  firehose {
    delivery_stream_name = aws_kinesis_firehose_delivery_stream.iot_topic_rule_firehose_stream.name
    role_arn             = aws_iam_role.iot_topic_rule_role.arn
  }
}