data "aws_iam_policy_document" "iot_topic_rule_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iot_topic_rule_role" {
  name               = "iotRuleRole"
  assume_role_policy = data.aws_iam_policy_document.iot_topic_rule_assume_role.json
}

data "aws_iam_policy_document" "iam_policy_for_iot_topic_rule_firehose" {
  statement {
    effect    = "Allow"
    actions   = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [aws_kinesis_firehose_delivery_stream.iot_topic_rule_firehose_stream.arn]
  }
}


resource "aws_iam_role_policy" "iam_policy_for_iot_rule_firehose" {
  name   = "iotRuleFirehosePolicy"
  role   = aws_iam_role.iot_topic_rule_role.id
  policy = data.aws_iam_policy_document.iam_policy_for_iot_topic_rule_firehose.json
}