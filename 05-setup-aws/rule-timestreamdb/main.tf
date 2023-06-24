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

# grafana workspace
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "grafana_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["grafana.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "StringLike"
      values   = ["arn:aws:grafana:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:/workspaces/*"]
      variable = "aws:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "grafana_timestream" {
  statement {
    effect  = "Allow"
    actions = [
      "timestream:CancelQuery",
      "timestream:DescribeDatabase",
      "timestream:DescribeEndpoints",
      "timestream:DescribeTable",
      "timestream:ListDatabases",
      "timestream:ListMeasures",
      "timestream:ListTables",
      "timestream:ListTagsForResource",
      "timestream:Select",
      "timestream:SelectValues",
      "timestream:DescribeScheduledQuery",
      "timestream:ListScheduledQueries",
      "timestream:DescribeBatchLoadTask",
      "timestream:ListBatchLoadTasks",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "grafana_logs" {
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

resource "aws_iam_role" "grafana" {
  name               = "IotTopicRuleGrafanaRole"
  assume_role_policy = data.aws_iam_policy_document.grafana_assume.json
}

resource "aws_iam_role_policy" "grafana_timestream" {
  name   = "IotTopicRuleGrafanaTimestreamPolicy"
  role   = aws_iam_role.grafana.id
  policy = data.aws_iam_policy_document.grafana_timestream.json
}

resource "aws_iam_role_policy" "grafana_logs" {
  name   = "IotTopicRuleGrafanaLogsPolicy"
  role   = aws_iam_role.grafana.id
  policy = data.aws_iam_policy_document.grafana_logs.json
}


#################
# TIMESTREAM DB #
#################

resource "aws_timestreamwrite_database" "iot" {
  database_name = local.database.name
}

resource "aws_timestreamwrite_table" "sensor" {
  database_name = aws_timestreamwrite_database.iot.database_name
  table_name    = local.table.name

  retention_properties {
    memory_store_retention_period_in_hours  = 8
    magnetic_store_retention_period_in_days = 7
  }
}


###########
# GRAFANA #
###########

# SSO User
data "aws_ssoadmin_instances" "sso" {}

resource "aws_identitystore_user" "grafana" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]

  user_name = local.grafana_user.user_name
  emails {
    value   = local.grafana_user.email
    primary = true
  }

  display_name = local.grafana_user.display_name
  name {
    given_name  = local.grafana_user.given_name
    family_name = local.grafana_user.family_name
  }
}

# Workspace
resource "aws_grafana_workspace" "iot" {
  name                     = local.grafana_workspace.name
  account_access_type      = local.grafana_workspace.account_access_type
  data_sources             = local.grafana_workspace.data_sources
  authentication_providers = local.grafana_workspace.authentication_providers
  permission_type          = local.grafana_workspace.permission_type
  role_arn                 = aws_iam_role.grafana.arn
}

resource "aws_grafana_role_association" "iot" {
  role         = "ADMIN"
  user_ids     = [aws_identitystore_user.grafana.user_id]
  workspace_id = aws_grafana_workspace.iot.id
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