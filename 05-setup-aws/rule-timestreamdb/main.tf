#############
# IAM ROlES #
#############

# iot topic rule
data "aws_iam_policy_document" "iot_topic_rule_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iot_topic_rule_write" {
  statement {
    effect  = "Allow"
    actions = [
      "timestream:WriteRecords",
    ]
    resources = [aws_timestreamwrite_table.sensor.arn]
  }
}

data "aws_iam_policy_document" "iot_topic_rule_describe" {
  statement {
    effect  = "Allow"
    actions = [
      "timestream:DescribeEndpoints",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "iot_topic_rule" {
  name               = "IotTopicRuleTimestreamRole"
  assume_role_policy = data.aws_iam_policy_document.iot_topic_rule_assume.json
}

resource "aws_iam_role_policy" "iot_topic_rule_write" {
  name   = "IotTopicRuleTimestreamWritePolicy"
  role   = aws_iam_role.iot_topic_rule.id
  policy = data.aws_iam_policy_document.iot_topic_rule_write.json
}

resource "aws_iam_role_policy" "iot_topic_rule_describe" {
  name   = "IotTopicRuleTimestreamDescribePolicy"
  role   = aws_iam_role.iot_topic_rule.id
  policy = data.aws_iam_policy_document.iot_topic_rule_describe.json
}


#################
# TIMESTREAM DB #
#################

resource "aws_timestreamwrite_database" "iot" {
  database_name = local.database.name
}

resource "aws_timestreamwrite_table" "sensor" {
  database_name = aws_timestreamwrite_database.iot.database_name
  table_name = local.table.name

  retention_properties {
    memory_store_retention_period_in_hours  = 8
    magnetic_store_retention_period_in_days = 7
  }
}


##############
# TOPIC RULE #
##############

resource "aws_iot_topic_rule" "iot_topic_rule_firehose" {
  name        = local.rule.name
  description = local.rule.description
  enabled     = local.rule.enabled
  sql         = local.rule.sql
  sql_version = local.rule.sql_version

  timestream {
    database_name = aws_timestreamwrite_database.iot.database_name
    table_name    = aws_timestreamwrite_table.sensor.table_name
    role_arn      = aws_iam_role.iot_topic_rule.arn
    dimension {
      name  = "type"
      value = "$${type}"
    }
  }

  depends_on = [
    aws_timestreamwrite_database.iot,
    aws_timestreamwrite_table.sensor
  ]
}