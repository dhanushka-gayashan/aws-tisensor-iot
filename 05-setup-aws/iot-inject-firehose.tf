resource "aws_kinesis_firehose_delivery_stream" "iot_topic_rule_firehose_stream" {
  name        = "iot-topic-rule-firehose-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.iot_firehose_role.arn
    bucket_arn = aws_s3_bucket.iot_inject_bucket.arn
  }
}