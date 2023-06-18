#############
# IAM ROlES #
#############

# iot topic rule
data "aws_iam_policy_document" "rule_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rule" {
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
    ]
    resources = [aws_dynamodb_table.raw.arn]
  }
}

resource "aws_iam_role" "iot_topic_rule" {
  name               = "IotTopicRuleRole"
  assume_role_policy = data.aws_iam_policy_document.rule_assume.json
}

resource "aws_iam_role_policy" "iot_topic_rule" {
  name   = "IotTopicRuleDynamodbPolicy"
  role   = aws_iam_role.iot_topic_rule.id
  policy = data.aws_iam_policy_document.rule.json
}

# process lambda
data "aws_iam_policy_document" "process_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "process_table" {
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams",
    ]
    resources = [aws_dynamodb_table.output[*].arn]
  }
}

data "aws_iam_policy_document" "process_log" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "process" {
  name               = "IotDataProcessLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.process_assume.json
}

resource "aws_iam_role_policy" "process_table" {
  name   = "IotDataProcessLambdaTablePolicy"
  role   = aws_iam_role.process.id
  policy = data.aws_iam_policy_document.process_table.json
}

resource "aws_iam_role_policy" "process_log" {
  name   = "IotDataProcessLambdaLogPolicy"
  role   = aws_iam_role.process.id
  policy = data.aws_iam_policy_document.process_log.json
}


######################
# RAW DYNAMODB TABLE #
######################

resource "aws_dynamodb_table" "raw" {
  name             = local.raw.name
  billing_mode     = local.raw.billing_mode
  read_capacity    = local.raw.read_capacity
  write_capacity   = local.raw.write_capacity
  hash_key         = local.raw.hash_key
  range_key        = local.raw.range_key
  stream_enabled   = local.raw.stream_enabled
  stream_view_type = local.raw.stream_view_type

  attribute {
    name = local.raw.hash_key
    type = "S"
  }

  attribute {
    name = local.raw.range_key
    type = "S"
  }

  ttl {
    enabled        = local.raw.ttl_enable
    attribute_name = local.raw.ttl_attribute
  }
}


##########################
# OUTPUT DYNAMODB TABLES #
##########################

resource "aws_dynamodb_table" "output" {
  for_each = local.outputs

  name             = local.raw.name
  billing_mode     = local.raw.billing_mode
  read_capacity    = local.raw.read_capacity
  write_capacity   = local.raw.write_capacity
  hash_key         = local.raw.hash_key
  range_key        = local.raw.range_key

  attribute {
    name = local.raw.hash_key
    type = "S"
  }

  attribute {
    name = local.raw.range_key
    type = "S"
  }

  ttl {
    enabled        = local.raw.ttl_enable
    attribute_name = local.raw.ttl_attribute
  }
}


##########
# LAMBDA #
##########

resource "aws_lambda_function" "process" {
  function_name                   = local.lambda.function_name
  handler                         = local.lambda.handler
  runtime                         = local.lambda.runtime
  role                            = aws_iam_role.process.arn
  filename                        = "${path.module}/${local.lambda.filename}"
  source_code_hash                = filebase64sha256("${path.module}/${local.lambda.filename}")
  memory_size                     = local.lambda.memory_size
  timeout                         = local.lambda.timeout

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "process" {
  name              = "/aws/lambda/${aws_lambda_function.process.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_event_source_mapping" "process" {
  event_source_arn  = aws_dynamodb_table.raw.stream_arn
  function_name     = aws_lambda_function.process.arn
  starting_position = "LATEST"
}


##############
# TOPIC RULE #
##############

resource "aws_iot_topic_rule" "dynamodb" {
  name        = local.rule.name
  description = local.rule.description
  enabled     = local.rule.enabled
  sql         = local.rule.sql
  sql_version = local.rule.sql_version

  dynamodbv2 {
    put_item {
      table_name = local.raw.name
    }
    role_arn = aws_iam_role.iot_topic_rule.arn
  }
}